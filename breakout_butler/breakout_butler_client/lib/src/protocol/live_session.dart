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

/// An active/live session with its URL tag
abstract class LiveSession implements _i1.SerializableModel {
  LiveSession._({
    this.id,
    required this.sessionId,
    required this.urlTag,
    required this.isActive,
    required this.transcript,
    required this.startedAt,
    this.expiresAt,
  });

  factory LiveSession({
    int? id,
    required int sessionId,
    required String urlTag,
    required bool isActive,
    required String transcript,
    required DateTime startedAt,
    DateTime? expiresAt,
  }) = _LiveSessionImpl;

  factory LiveSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return LiveSession(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      urlTag: jsonSerialization['urlTag'] as String,
      isActive: jsonSerialization['isActive'] as bool,
      transcript: jsonSerialization['transcript'] as String,
      startedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The persistent session this live session refers to
  int sessionId;

  /// The URL tag set by professor (e.g., "psych101")
  String urlTag;

  /// Whether the session is currently active
  bool isActive;

  /// Full accumulated transcript from butler
  String transcript;

  /// When this live session was started
  DateTime startedAt;

  /// When this live session expires/ended
  DateTime? expiresAt;

  /// Returns a shallow copy of this [LiveSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LiveSession copyWith({
    int? id,
    int? sessionId,
    String? urlTag,
    bool? isActive,
    String? transcript,
    DateTime? startedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LiveSession',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'urlTag': urlTag,
      'isActive': isActive,
      'transcript': transcript,
      'startedAt': startedAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LiveSessionImpl extends LiveSession {
  _LiveSessionImpl({
    int? id,
    required int sessionId,
    required String urlTag,
    required bool isActive,
    required String transcript,
    required DateTime startedAt,
    DateTime? expiresAt,
  }) : super._(
         id: id,
         sessionId: sessionId,
         urlTag: urlTag,
         isActive: isActive,
         transcript: transcript,
         startedAt: startedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [LiveSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LiveSession copyWith({
    Object? id = _Undefined,
    int? sessionId,
    String? urlTag,
    bool? isActive,
    String? transcript,
    DateTime? startedAt,
    Object? expiresAt = _Undefined,
  }) {
    return LiveSession(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      urlTag: urlTag ?? this.urlTag,
      isActive: isActive ?? this.isActive,
      transcript: transcript ?? this.transcript,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
    );
  }
}
