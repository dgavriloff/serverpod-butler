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
import 'butler_response.dart' as _i2;
import 'drawing_stroke.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'live_session.dart' as _i5;
import 'presence_update.dart' as _i6;
import 'room.dart' as _i7;
import 'room_update.dart' as _i8;
import 'session.dart' as _i9;
import 'transcript_chunk.dart' as _i10;
import 'transcript_update.dart' as _i11;
import 'user_presence.dart' as _i12;
import 'package:breakout_butler_client/src/protocol/room.dart' as _i13;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i14;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i15;
export 'butler_response.dart';
export 'drawing_stroke.dart';
export 'greetings/greeting.dart';
export 'live_session.dart';
export 'presence_update.dart';
export 'room.dart';
export 'room_update.dart';
export 'session.dart';
export 'transcript_chunk.dart';
export 'transcript_update.dart';
export 'user_presence.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ButlerResponse) {
      return _i2.ButlerResponse.fromJson(data) as T;
    }
    if (t == _i3.DrawingStroke) {
      return _i3.DrawingStroke.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.LiveSession) {
      return _i5.LiveSession.fromJson(data) as T;
    }
    if (t == _i6.PresenceUpdate) {
      return _i6.PresenceUpdate.fromJson(data) as T;
    }
    if (t == _i7.Room) {
      return _i7.Room.fromJson(data) as T;
    }
    if (t == _i8.RoomUpdate) {
      return _i8.RoomUpdate.fromJson(data) as T;
    }
    if (t == _i9.ClassSession) {
      return _i9.ClassSession.fromJson(data) as T;
    }
    if (t == _i10.TranscriptChunk) {
      return _i10.TranscriptChunk.fromJson(data) as T;
    }
    if (t == _i11.TranscriptUpdate) {
      return _i11.TranscriptUpdate.fromJson(data) as T;
    }
    if (t == _i12.UserPresence) {
      return _i12.UserPresence.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ButlerResponse?>()) {
      return (data != null ? _i2.ButlerResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DrawingStroke?>()) {
      return (data != null ? _i3.DrawingStroke.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.LiveSession?>()) {
      return (data != null ? _i5.LiveSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.PresenceUpdate?>()) {
      return (data != null ? _i6.PresenceUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Room?>()) {
      return (data != null ? _i7.Room.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.RoomUpdate?>()) {
      return (data != null ? _i8.RoomUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ClassSession?>()) {
      return (data != null ? _i9.ClassSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.TranscriptChunk?>()) {
      return (data != null ? _i10.TranscriptChunk.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.TranscriptUpdate?>()) {
      return (data != null ? _i11.TranscriptUpdate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.UserPresence?>()) {
      return (data != null ? _i12.UserPresence.fromJson(data) : null) as T;
    }
    if (t == List<_i12.UserPresence>) {
      return (data as List)
              .map((e) => deserialize<_i12.UserPresence>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i12.UserPresence>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i12.UserPresence>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i7.Room>) {
      return (data as List).map((e) => deserialize<_i7.Room>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i7.Room>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i7.Room>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i10.TranscriptChunk>) {
      return (data as List)
              .map((e) => deserialize<_i10.TranscriptChunk>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i10.TranscriptChunk>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i10.TranscriptChunk>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i13.Room>) {
      return (data as List).map((e) => deserialize<_i13.Room>(e)).toList() as T;
    }
    try {
      return _i14.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i15.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ButlerResponse => 'ButlerResponse',
      _i3.DrawingStroke => 'DrawingStroke',
      _i4.Greeting => 'Greeting',
      _i5.LiveSession => 'LiveSession',
      _i6.PresenceUpdate => 'PresenceUpdate',
      _i7.Room => 'Room',
      _i8.RoomUpdate => 'RoomUpdate',
      _i9.ClassSession => 'ClassSession',
      _i10.TranscriptChunk => 'TranscriptChunk',
      _i11.TranscriptUpdate => 'TranscriptUpdate',
      _i12.UserPresence => 'UserPresence',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'breakout_butler.',
        '',
      );
    }

    switch (data) {
      case _i2.ButlerResponse():
        return 'ButlerResponse';
      case _i3.DrawingStroke():
        return 'DrawingStroke';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.LiveSession():
        return 'LiveSession';
      case _i6.PresenceUpdate():
        return 'PresenceUpdate';
      case _i7.Room():
        return 'Room';
      case _i8.RoomUpdate():
        return 'RoomUpdate';
      case _i9.ClassSession():
        return 'ClassSession';
      case _i10.TranscriptChunk():
        return 'TranscriptChunk';
      case _i11.TranscriptUpdate():
        return 'TranscriptUpdate';
      case _i12.UserPresence():
        return 'UserPresence';
    }
    className = _i14.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i15.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ButlerResponse') {
      return deserialize<_i2.ButlerResponse>(data['data']);
    }
    if (dataClassName == 'DrawingStroke') {
      return deserialize<_i3.DrawingStroke>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'LiveSession') {
      return deserialize<_i5.LiveSession>(data['data']);
    }
    if (dataClassName == 'PresenceUpdate') {
      return deserialize<_i6.PresenceUpdate>(data['data']);
    }
    if (dataClassName == 'Room') {
      return deserialize<_i7.Room>(data['data']);
    }
    if (dataClassName == 'RoomUpdate') {
      return deserialize<_i8.RoomUpdate>(data['data']);
    }
    if (dataClassName == 'ClassSession') {
      return deserialize<_i9.ClassSession>(data['data']);
    }
    if (dataClassName == 'TranscriptChunk') {
      return deserialize<_i10.TranscriptChunk>(data['data']);
    }
    if (dataClassName == 'TranscriptUpdate') {
      return deserialize<_i11.TranscriptUpdate>(data['data']);
    }
    if (dataClassName == 'UserPresence') {
      return deserialize<_i12.UserPresence>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i14.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i15.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i14.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i15.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
