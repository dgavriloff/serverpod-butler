/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'room.dart' as _i2;
import 'transcript_chunk.dart' as _i3;
import 'package:breakout_butler_client/src/protocol/protocol.dart' as _i4;

/// A classroom session created by a professor
abstract class ClassSession implements _i1.SerializableModel {
  ClassSession._({
    this.id,
    required this.name,
    required this.roomCount,
    required this.createdAt,
    this.rooms,
    this.transcriptChunks,
  });

  factory ClassSession({
    int? id,
    required String name,
    required int roomCount,
    required DateTime createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  }) = _ClassSessionImpl;

  factory ClassSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClassSession(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      roomCount: jsonSerialization['roomCount'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      rooms: jsonSerialization['rooms'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i2.Room>>(
              jsonSerialization['rooms'],
            ),
      transcriptChunks: jsonSerialization['transcriptChunks'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.TranscriptChunk>>(
              jsonSerialization['transcriptChunks'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Session name (e.g., "Milgram Discussion")
  String name;

  /// Number of breakout rooms
  int roomCount;

  /// When the session was created
  DateTime createdAt;

  /// Rooms belonging to this session
  List<_i2.Room>? rooms;

  /// Transcript chunks from this session
  List<_i3.TranscriptChunk>? transcriptChunks;

  /// Returns a shallow copy of this [ClassSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClassSession copyWith({
    int? id,
    String? name,
    int? roomCount,
    DateTime? createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClassSession',
      if (id != null) 'id': id,
      'name': name,
      'roomCount': roomCount,
      'createdAt': createdAt.toJson(),
      if (rooms != null) 'rooms': rooms?.toJson(valueToJson: (v) => v.toJson()),
      if (transcriptChunks != null)
        'transcriptChunks': transcriptChunks?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ClassSessionImpl extends ClassSession {
  _ClassSessionImpl({
    int? id,
    required String name,
    required int roomCount,
    required DateTime createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  }) : super._(
         id: id,
         name: name,
         roomCount: roomCount,
         createdAt: createdAt,
         rooms: rooms,
         transcriptChunks: transcriptChunks,
       );

  /// Returns a shallow copy of this [ClassSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClassSession copyWith({
    Object? id = _Undefined,
    String? name,
    int? roomCount,
    DateTime? createdAt,
    Object? rooms = _Undefined,
    Object? transcriptChunks = _Undefined,
  }) {
    return ClassSession(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      roomCount: roomCount ?? this.roomCount,
      createdAt: createdAt ?? this.createdAt,
      rooms: rooms is List<_i2.Room>?
          ? rooms
          : this.rooms?.map((e0) => e0.copyWith()).toList(),
      transcriptChunks: transcriptChunks is List<_i3.TranscriptChunk>?
          ? transcriptChunks
          : this.transcriptChunks?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
