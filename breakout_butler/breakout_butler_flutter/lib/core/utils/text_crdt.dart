import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';

import 'package:crdt/crdt.dart';

/// Log to browser console (works in WASM)
void _consoleLog(String message) {
  _jsConsoleLog(message.toJS);
}

@JS('console.log')
external void _jsConsoleLog(JSString message);

/// A character in the CRDT text with a unique fractional position.
class CrdtChar {
  CrdtChar({
    required this.id,
    required this.position,
    required this.char,
    required this.deleted,
    required this.hlc,
  });

  factory CrdtChar.fromJson(Map<String, dynamic> json) {
    return CrdtChar(
      id: json['id'] as String,
      position: (json['position'] as num).toDouble(),
      char: json['char'] as String,
      deleted: json['deleted'] as bool? ?? false,
      hlc: Hlc.parse(json['hlc'] as String),
    );
  }

  /// Unique identifier for this character
  final String id;

  /// Fractional position (0.0 to 1.0) for ordering
  final double position;

  /// The actual character (single char)
  final String char;

  /// Tombstone flag for deletion
  final bool deleted;

  /// Hybrid logical clock for conflict resolution
  final Hlc hlc;

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'char': char,
        'deleted': deleted,
        'hlc': hlc.toString(),
      };

  CrdtChar copyWith({bool? deleted, Hlc? hlc}) {
    return CrdtChar(
      id: id,
      position: position,
      char: char,
      deleted: deleted ?? this.deleted,
      hlc: hlc ?? this.hlc,
    );
  }
}

/// Text CRDT using fractional indexing for collaborative editing.
///
/// Each character has a unique position between 0 and 1. When inserting
/// between two characters, we pick a position halfway between them.
/// Deletions are tombstoned (marked deleted) rather than removed.
class TextCrdt {
  factory TextCrdt({String? nodeId}) {
    final id = nodeId ?? _generateNodeId();
    return TextCrdt._(id, Hlc.zero(id));
  }

  TextCrdt._(this._nodeId, this._hlc);

  final String _nodeId;
  Hlc _hlc;

  /// All characters including tombstones, sorted by position
  final List<CrdtChar> _chars = [];

  /// Get visible text (excluding tombstones), sorted by position
  String get text {
    final visible = _chars.where((c) => !c.deleted).toList()
      ..sort((a, b) {
        final posCmp = a.position.compareTo(b.position);
        if (posCmp != 0) return posCmp;
        final hlcCmp = a.hlc.compareTo(b.hlc);
        if (hlcCmp != 0) return hlcCmp;
        return a.id.compareTo(b.id);
      });
    return visible.map((c) => c.char).join();
  }

  /// Get the current state as JSON for persistence/sync
  String toJson() {
    return jsonEncode(_chars.map((c) => c.toJson()).toList());
  }

  /// Load state from JSON
  void loadFromJson(String json) {
    if (json.isEmpty) {
      _chars.clear();
      return;
    }
    try {
      final list = jsonDecode(json) as List<dynamic>;
      _chars.clear();
      for (final item in list) {
        _chars.add(CrdtChar.fromJson(item as Map<String, dynamic>));
      }
      _sortChars();
      _deduplicateChars();
    } catch (_) {
      // Corrupt data, start fresh
      _chars.clear();
    }
  }

  /// Merge remote changes into local state
  void merge(String remoteJson) {
    if (remoteJson.isEmpty) return;

    try {
      final remoteList = jsonDecode(remoteJson) as List<dynamic>;
      final remoteChars = remoteList
          .map((item) => CrdtChar.fromJson(item as Map<String, dynamic>))
          .toList();

      _consoleLog('[CRDT] merge: ${remoteChars.length} remote chars');
      var newCount = 0;
      var updatedCount = 0;
      var restoredCount = 0;

      for (final remote in remoteChars) {
        final localIndex = _chars.indexWhere((c) => c.id == remote.id);

        if (localIndex == -1) {
          // New character from remote
          _chars.add(remote);
          newCount++;
        } else {
          // Existing character - use HLC to resolve conflicts
          final local = _chars[localIndex];
          if (remote.hlc.compareTo(local.hlc) > 0) {
            // Check if this is restoring a deleted character
            if (local.deleted && !remote.deleted) {
              restoredCount++;
              _consoleLog('[CRDT] merge RESTORE: char="${remote.char}" id=${remote.id} localHlc=${local.hlc} remoteHlc=${remote.hlc}');
            }
            _chars[localIndex] = remote;
            updatedCount++;
          }
        }

        // Update our HLC if remote is ahead
        if (remote.hlc.compareTo(_hlc) > 0) {
          _hlc = _hlc.merge(remote.hlc);
        }
      }

      _consoleLog('[CRDT] merge done: new=$newCount updated=$updatedCount restored=$restoredCount');
      _sortChars();
      _deduplicateChars();
    } catch (e) {
      _consoleLog('[CRDT] merge error: $e');
    }
  }

  /// Insert text at the given visible index
  void insert(int index, String textToInsert) {
    if (textToInsert.isEmpty) return;

    _hlc = _hlc.increment();

    // Find positions of neighbors (sorted by position)
    var visible = _chars.where((c) => !c.deleted).toList()
      ..sort((a, b) {
        final posCmp = a.position.compareTo(b.position);
        if (posCmp != 0) return posCmp;
        final hlcCmp = a.hlc.compareTo(b.hlc);
        if (hlcCmp != 0) return hlcCmp;
        return a.id.compareTo(b.id);
      });
    var leftPos = index > 0 ? visible[index - 1].position : 0.0;
    var rightPos = index < visible.length ? visible[index].position : 1.0;

    // If positions are too close, rebalance the entire document
    final minStep = 1e-10;
    if (rightPos - leftPos < minStep * (textToInsert.length + 1)) {
      _rebalancePositions();
      visible = _chars.where((c) => !c.deleted).toList()
        ..sort((a, b) {
          final posCmp = a.position.compareTo(b.position);
          if (posCmp != 0) return posCmp;
          final hlcCmp = a.hlc.compareTo(b.hlc);
          if (hlcCmp != 0) return hlcCmp;
          return a.id.compareTo(b.id);
        });
      leftPos = index > 0 ? visible[index - 1].position : 0.0;
      rightPos = index < visible.length ? visible[index].position : 1.0;
    }

    // Generate positions for each character
    final step = (rightPos - leftPos) / (textToInsert.length + 1);

    for (var i = 0; i < textToInsert.length; i++) {
      final position = leftPos + step * (i + 1);
      final char = CrdtChar(
        id: _generateCharId(),
        position: position,
        char: textToInsert[i],
        deleted: false,
        hlc: _hlc,
      );
      _chars.add(char);
    }

    _sortChars();
  }

  /// Rebalance all character positions to be evenly distributed
  void _rebalancePositions() {
    final visible = _chars.where((c) => !c.deleted).toList();
    if (visible.isEmpty) return;

    _hlc = _hlc.increment();
    final step = 1.0 / (visible.length + 1);

    for (var i = 0; i < visible.length; i++) {
      final oldChar = visible[i];
      final charIndex = _chars.indexWhere((c) => c.id == oldChar.id);
      if (charIndex != -1) {
        _chars[charIndex] = CrdtChar(
          id: oldChar.id,
          position: step * (i + 1),
          char: oldChar.char,
          deleted: oldChar.deleted,
          hlc: _hlc,
        );
      }
    }

    _sortChars();
  }

  /// Delete text in the given visible range
  void delete(int start, int end) {
    if (start >= end) return;

    _hlc = _hlc.increment();

    // Get visible chars sorted by position (same order as text getter)
    final visible = _chars.where((c) => !c.deleted).toList()
      ..sort((a, b) {
        final posCmp = a.position.compareTo(b.position);
        if (posCmp != 0) return posCmp;
        final hlcCmp = a.hlc.compareTo(b.hlc);
        if (hlcCmp != 0) return hlcCmp;
        return a.id.compareTo(b.id);
      });

    _consoleLog('[CRDT] delete: start=$start, end=$end, visibleLen=${visible.length}');

    // Log IDs of chars we're about to delete
    final toDelete = visible.skip(start).take(end - start).toList();
    _consoleLog('[CRDT] deleting chars: "${toDelete.map((c) => c.char == '\n' ? '\\n' : c.char).join()}"');
    _consoleLog('[CRDT] deleting IDs: ${toDelete.map((c) => c.id).join(", ")}');

    // Collect all IDs to delete
    final idsToDelete = <String>{};
    for (var i = start; i < end && i < visible.length; i++) {
      idsToDelete.add(visible[i].id);
    }

    // Mark ALL occurrences of these IDs as deleted (handles duplicates)
    var deletedCount = 0;
    for (var i = 0; i < _chars.length; i++) {
      if (idsToDelete.contains(_chars[i].id) && !_chars[i].deleted) {
        _chars[i] = _chars[i].copyWith(
          deleted: true,
          hlc: _hlc,
        );
        deletedCount++;
      }
    }
    _consoleLog('[CRDT] delete result: deleted=$deletedCount entries for ${idsToDelete.length} IDs');

    // Verify deletion took effect on the specific chars we tried to delete
    final charsWeDeleted = visible.skip(start).take(end - start).toList();
    for (final c in charsWeDeleted) {
      final inChars = _chars.firstWhere((x) => x.id == c.id, orElse: () => c);
      if (!inChars.deleted) {
        _consoleLog('[CRDT] BUG: char "${c.char}" id=${c.id.substring(0, 20)} still not deleted!');
      }
    }

    // Check for duplicates - count all visible chars matching the deleted pattern
    final afterVisible = _chars.where((c) => !c.deleted).toList()
      ..sort((a, b) {
        final posCmp = a.position.compareTo(b.position);
        if (posCmp != 0) return posCmp;
        final hlcCmp = a.hlc.compareTo(b.hlc);
        if (hlcCmp != 0) return hlcCmp;
        return a.id.compareTo(b.id);
      });
    _consoleLog('[CRDT] after delete: ${afterVisible.length} visible chars');

    // Count occurrences of the pattern we tried to delete
    final charsToFind = visible.skip(start).take(end - start).map((c) => c.char).toList();
    var patternCount = 0;
    for (var i = 0; i <= afterVisible.length - charsToFind.length; i++) {
      var match = true;
      for (var j = 0; j < charsToFind.length && match; j++) {
        if (afterVisible[i + j].char != charsToFind[j]) match = false;
      }
      if (match) {
        patternCount++;
        final foundIds = afterVisible.skip(i).take(charsToFind.length).map((c) => c.id).toList();
        _consoleLog('[CRDT] found at idx $i IDs: ${foundIds.join(", ")}');
        // Check if any of these IDs match the ones we deleted
        final overlap = foundIds.where((id) => toDelete.any((d) => d.id == id)).length;
        if (overlap > 0) {
          _consoleLog('[CRDT] BUG: $overlap IDs overlap with deleted chars!');
        }
      }
    }
    _consoleLog('[CRDT] pattern "$charsToFind" found $patternCount times after delete');
  }

  /// Replace all text (used for initial sync or full replacement)
  void replaceAll(String newText) {
    _hlc = _hlc.increment();
    _chars.clear();

    if (newText.isEmpty) return;

    final step = 1.0 / (newText.length + 1);
    for (var i = 0; i < newText.length; i++) {
      _chars.add(CrdtChar(
        id: _generateCharId(),
        position: step * (i + 1),
        char: newText[i],
        deleted: false,
        hlc: _hlc,
      ));
    }
  }

  /// Apply a text change from a TextField (diff-based)
  void applyChange(String oldText, String newText) {
    if (oldText == newText) return;

    _consoleLog('[CRDT] applyChange: oldLen=${oldText.length}, newLen=${newText.length}');

    // Find common prefix
    var prefixLen = 0;
    while (prefixLen < oldText.length &&
        prefixLen < newText.length &&
        oldText[prefixLen] == newText[prefixLen]) {
      prefixLen++;
    }

    // Find common suffix (after prefix)
    var suffixLen = 0;
    while (suffixLen < oldText.length - prefixLen &&
        suffixLen < newText.length - prefixLen &&
        oldText[oldText.length - 1 - suffixLen] ==
            newText[newText.length - 1 - suffixLen]) {
      suffixLen++;
    }

    final deleteStart = prefixLen;
    final deleteEnd = oldText.length - suffixLen;
    final insertText = newText.substring(prefixLen, newText.length - suffixLen);

    _consoleLog('[CRDT] diff: prefixLen=$prefixLen, suffixLen=$suffixLen, deleteStart=$deleteStart, deleteEnd=$deleteEnd');
    _consoleLog('[CRDT] diff: deleteCount=${deleteEnd - deleteStart}, insertLen=${insertText.length}');

    // Delete old characters
    if (deleteEnd > deleteStart) {
      delete(deleteStart, deleteEnd);
    }

    // Insert new characters
    if (insertText.isNotEmpty) {
      insert(deleteStart, insertText);
    }
  }

  void _sortChars() {
    _chars.sort((a, b) {
      final posCmp = a.position.compareTo(b.position);
      if (posCmp != 0) return posCmp;
      // Tie-breaker: use HLC then ID
      final hlcCmp = a.hlc.compareTo(b.hlc);
      if (hlcCmp != 0) return hlcCmp;
      return a.id.compareTo(b.id);
    });
  }

  /// Remove duplicate characters. Two types of duplicates:
  /// 1. Same ID appearing multiple times (keep highest HLC)
  /// 2. Same char at very similar positions (keep highest HLC)
  void _deduplicateChars() {
    if (_chars.isEmpty) return;

    // First pass: deduplicate by ID (IDs should be unique)
    final seenIds = <String, int>{};
    final idDuplicateIndices = <int>[];

    for (var i = 0; i < _chars.length; i++) {
      final id = _chars[i].id;
      if (seenIds.containsKey(id)) {
        final existingIdx = seenIds[id]!;
        final existing = _chars[existingIdx];
        final current = _chars[i];

        // Keep the one with higher HLC (or if equal, keep deleted=true version)
        final hlcCmp = current.hlc.compareTo(existing.hlc);
        if (hlcCmp > 0 || (hlcCmp == 0 && current.deleted && !existing.deleted)) {
          // Current is newer/more authoritative, remove existing
          idDuplicateIndices.add(existingIdx);
          seenIds[id] = i;
        } else {
          // Existing is newer/more authoritative, remove current
          idDuplicateIndices.add(i);
        }
      } else {
        seenIds[id] = i;
      }
    }

    if (idDuplicateIndices.isNotEmpty) {
      _consoleLog('[CRDT] removing ${idDuplicateIndices.length} duplicate IDs');
      // Remove in reverse order to preserve indices
      idDuplicateIndices.sort((a, b) => b.compareTo(a));
      for (final idx in idDuplicateIndices) {
        _chars.removeAt(idx);
      }
    }

    // Sort after ID deduplication
    _sortChars();

    // Second pass: deduplicate by position+char
    const posEpsilon = 0.0001;
    final toRemove = <String>{};

    for (var i = 0; i < _chars.length - 1; i++) {
      final current = _chars[i];
      if (toRemove.contains(current.id)) continue;

      for (var j = i + 1; j < _chars.length; j++) {
        final other = _chars[j];
        if (toRemove.contains(other.id)) continue;

        // Check if positions are very close and same character
        if ((current.position - other.position).abs() < posEpsilon &&
            current.char == other.char) {
          // Keep the one with higher HLC, remove the other
          if (current.hlc.compareTo(other.hlc) >= 0) {
            toRemove.add(other.id);
          } else {
            toRemove.add(current.id);
            break; // Current is removed, move to next
          }
        } else if (other.position - current.position >= posEpsilon) {
          // Positions are now too far apart (sorted), stop checking
          break;
        }
      }
    }

    if (toRemove.isNotEmpty) {
      _consoleLog('[CRDT] removing ${toRemove.length} position duplicates');
      _chars.removeWhere((c) => toRemove.contains(c.id));
    }
  }

  String _generateCharId() {
    return '$_nodeId-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';
  }

  static String _generateNodeId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  static final _random = Random();
}
