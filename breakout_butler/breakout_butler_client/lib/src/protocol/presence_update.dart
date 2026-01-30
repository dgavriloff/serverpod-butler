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
import 'user_presence.dart' as _i2;
import 'package:breakout_butler_client/src/protocol/protocol.dart' as _i3;

/// Lightweight presence update (sent frequently without full content)
abstract class PresenceUpdate implements _i1.SerializableModel {
  PresenceUpdate._({
    required this.roomNumber,
    required this.user,
    this.joined,
  });

  factory PresenceUpdate({
    required int roomNumber,
    required _i2.UserPresence user,
    bool? joined,
  }) = _PresenceUpdateImpl;

  factory PresenceUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return PresenceUpdate(
      roomNumber: jsonSerialization['roomNumber'] as int,
      user: _i3.Protocol().deserialize<_i2.UserPresence>(
        jsonSerialization['user'],
      ),
      joined: jsonSerialization['joined'] as bool?,
    );
  }

  /// Room number
  int roomNumber;

  /// The user whose presence changed
  _i2.UserPresence user;

  /// Whether user joined (true) or left (false), null = just an update
  bool? joined;

  /// Returns a shallow copy of this [PresenceUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PresenceUpdate copyWith({
    int? roomNumber,
    _i2.UserPresence? user,
    bool? joined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PresenceUpdate',
      'roomNumber': roomNumber,
      'user': user.toJson(),
      if (joined != null) 'joined': joined,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PresenceUpdateImpl extends PresenceUpdate {
  _PresenceUpdateImpl({
    required int roomNumber,
    required _i2.UserPresence user,
    bool? joined,
  }) : super._(
         roomNumber: roomNumber,
         user: user,
         joined: joined,
       );

  /// Returns a shallow copy of this [PresenceUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PresenceUpdate copyWith({
    int? roomNumber,
    _i2.UserPresence? user,
    Object? joined = _Undefined,
  }) {
    return PresenceUpdate(
      roomNumber: roomNumber ?? this.roomNumber,
      user: user ?? this.user.copyWith(),
      joined: joined is bool? ? joined : this.joined,
    );
  }
}
