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

/// A breakout room workspace
abstract class Room implements _i1.SerializableModel {
  Room._({
    this.id,
    required this.sessionId,
    required this.roomNumber,
    required this.content,
    required this.updatedAt,
  });

  factory Room({
    int? id,
    required int sessionId,
    required int roomNumber,
    required String content,
    required DateTime updatedAt,
  }) = _RoomImpl;

  factory Room.fromJson(Map<String, dynamic> jsonSerialization) {
    return Room(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      roomNumber: jsonSerialization['roomNumber'] as int,
      content: jsonSerialization['content'] as String,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The session this room belongs to
  int sessionId;

  /// Room number (matches Zoom breakout room number)
  int roomNumber;

  /// Collaborative text document content
  String content;

  /// Last updated timestamp
  DateTime updatedAt;

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Room copyWith({
    int? id,
    int? sessionId,
    int? roomNumber,
    String? content,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'roomNumber': roomNumber,
      'content': content,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomImpl extends Room {
  _RoomImpl({
    int? id,
    required int sessionId,
    required int roomNumber,
    required String content,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         sessionId: sessionId,
         roomNumber: roomNumber,
         content: content,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Room copyWith({
    Object? id = _Undefined,
    int? sessionId,
    int? roomNumber,
    String? content,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      roomNumber: roomNumber ?? this.roomNumber,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
