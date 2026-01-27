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

/// Real-time update for room content (not stored in database)
abstract class RoomUpdate implements _i1.SerializableModel {
  RoomUpdate._({
    required this.roomNumber,
    required this.content,
    required this.timestamp,
  });

  factory RoomUpdate({
    required int roomNumber,
    required String content,
    required DateTime timestamp,
  }) = _RoomUpdateImpl;

  factory RoomUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomUpdate(
      roomNumber: jsonSerialization['roomNumber'] as int,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  /// Room number being updated
  int roomNumber;

  /// New content
  String content;

  /// Timestamp of update
  DateTime timestamp;

  /// Returns a shallow copy of this [RoomUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RoomUpdate copyWith({
    int? roomNumber,
    String? content,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomUpdate',
      'roomNumber': roomNumber,
      'content': content,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RoomUpdateImpl extends RoomUpdate {
  _RoomUpdateImpl({
    required int roomNumber,
    required String content,
    required DateTime timestamp,
  }) : super._(
         roomNumber: roomNumber,
         content: content,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [RoomUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RoomUpdate copyWith({
    int? roomNumber,
    String? content,
    DateTime? timestamp,
  }) {
    return RoomUpdate(
      roomNumber: roomNumber ?? this.roomNumber,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
