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
import 'package:serverpod/serverpod.dart' as _i1;

/// Real-time update for room content (not stored in database)
abstract class RoomUpdate
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RoomUpdate._({
    required this.roomNumber,
    required this.content,
    this.drawingData,
    required this.timestamp,
  });

  factory RoomUpdate({
    required int roomNumber,
    required String content,
    String? drawingData,
    required DateTime timestamp,
  }) = _RoomUpdateImpl;

  factory RoomUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomUpdate(
      roomNumber: jsonSerialization['roomNumber'] as int,
      content: jsonSerialization['content'] as String,
      drawingData: jsonSerialization['drawingData'] as String?,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  /// Room number being updated
  int roomNumber;

  /// New content
  String content;

  /// Freehand drawing data (JSON array of strokes), null = unchanged
  String? drawingData;

  /// Timestamp of update
  DateTime timestamp;

  /// Returns a shallow copy of this [RoomUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RoomUpdate copyWith({
    int? roomNumber,
    String? content,
    String? drawingData,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomUpdate',
      'roomNumber': roomNumber,
      'content': content,
      if (drawingData != null) 'drawingData': drawingData,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomUpdate',
      'roomNumber': roomNumber,
      'content': content,
      if (drawingData != null) 'drawingData': drawingData,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomUpdateImpl extends RoomUpdate {
  _RoomUpdateImpl({
    required int roomNumber,
    required String content,
    String? drawingData,
    required DateTime timestamp,
  }) : super._(
         roomNumber: roomNumber,
         content: content,
         drawingData: drawingData,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [RoomUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RoomUpdate copyWith({
    int? roomNumber,
    String? content,
    Object? drawingData = _Undefined,
    DateTime? timestamp,
  }) {
    return RoomUpdate(
      roomNumber: roomNumber ?? this.roomNumber,
      content: content ?? this.content,
      drawingData: drawingData is String? ? drawingData : this.drawingData,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
