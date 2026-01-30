import 'dart:convert';
import 'dart:math';

import 'package:crdt/crdt.dart';

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

  /// Get visible text (excluding tombstones)
  String get text {
    final visible = _chars.where((c) => !c.deleted).toList();
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

      for (final remote in remoteChars) {
        final localIndex = _chars.indexWhere((c) => c.id == remote.id);

        if (localIndex == -1) {
          // New character from remote
          _chars.add(remote);
        } else {
          // Existing character - use HLC to resolve conflicts
          final local = _chars[localIndex];
          if (remote.hlc.compareTo(local.hlc) > 0) {
            _chars[localIndex] = remote;
          }
        }

        // Update our HLC if remote is ahead
        if (remote.hlc.compareTo(_hlc) > 0) {
          _hlc = _hlc.merge(remote.hlc);
        }
      }

      _sortChars();
    } catch (_) {
      // Ignore corrupt remote data
    }
  }

  /// Insert text at the given visible index
  void insert(int index, String text) {
    if (text.isEmpty) return;

    _hlc = _hlc.increment();

    // Find positions of neighbors
    final visible = _chars.where((c) => !c.deleted).toList();
    final leftPos = index > 0 ? visible[index - 1].position : 0.0;
    final rightPos = index < visible.length ? visible[index].position : 1.0;

    // Generate positions for each character
    final step = (rightPos - leftPos) / (text.length + 1);

    for (var i = 0; i < text.length; i++) {
      final position = leftPos + step * (i + 1);
      final char = CrdtChar(
        id: _generateCharId(),
        position: position,
        char: text[i],
        deleted: false,
        hlc: _hlc,
      );
      _chars.add(char);
    }

    _sortChars();
  }

  /// Delete text in the given visible range
  void delete(int start, int end) {
    if (start >= end) return;

    _hlc = _hlc.increment();

    final visible = _chars.where((c) => !c.deleted).toList();
    for (var i = start; i < end && i < visible.length; i++) {
      final charId = visible[i].id;
      final charIndex = _chars.indexWhere((c) => c.id == charId);
      if (charIndex != -1) {
        _chars[charIndex] = _chars[charIndex].copyWith(
          deleted: true,
          hlc: _hlc,
        );
      }
    }
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

  String _generateCharId() {
    return '$_nodeId-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';
  }

  static String _generateNodeId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  static final _random = Random();
}
