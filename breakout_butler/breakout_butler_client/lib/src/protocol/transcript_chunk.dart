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

/// A chunk of transcribed audio from the professor
abstract class TranscriptChunk implements _i1.SerializableModel {
  TranscriptChunk._({
    this.id,
    required this.sessionId,
    required this.timestamp,
    required this.text,
  });

  factory TranscriptChunk({
    int? id,
    required int sessionId,
    required DateTime timestamp,
    required String text,
  }) = _TranscriptChunkImpl;

  factory TranscriptChunk.fromJson(Map<String, dynamic> jsonSerialization) {
    return TranscriptChunk(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      text: jsonSerialization['text'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The session this transcript belongs to
  int sessionId;

  /// When this chunk was transcribed
  DateTime timestamp;

  /// The transcribed text
  String text;

  /// Returns a shallow copy of this [TranscriptChunk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TranscriptChunk copyWith({
    int? id,
    int? sessionId,
    DateTime? timestamp,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TranscriptChunk',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'timestamp': timestamp.toJson(),
      'text': text,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TranscriptChunkImpl extends TranscriptChunk {
  _TranscriptChunkImpl({
    int? id,
    required int sessionId,
    required DateTime timestamp,
    required String text,
  }) : super._(
         id: id,
         sessionId: sessionId,
         timestamp: timestamp,
         text: text,
       );

  /// Returns a shallow copy of this [TranscriptChunk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TranscriptChunk copyWith({
    Object? id = _Undefined,
    int? sessionId,
    DateTime? timestamp,
    String? text,
  }) {
    return TranscriptChunk(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
    );
  }
}
