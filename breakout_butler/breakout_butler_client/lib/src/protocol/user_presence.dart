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

/// Represents a user's presence state in a room
abstract class UserPresence implements _i1.SerializableModel {
  UserPresence._({
    required this.userId,
    required this.displayName,
    required this.color,
    required this.textCursor,
    required this.isTyping,
    required this.drawingX,
    required this.drawingY,
    required this.isDrawing,
    required this.lastActive,
  });

  factory UserPresence({
    required String userId,
    required String displayName,
    required String color,
    required int textCursor,
    required bool isTyping,
    required double drawingX,
    required double drawingY,
    required bool isDrawing,
    required DateTime lastActive,
  }) = _UserPresenceImpl;

  factory UserPresence.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserPresence(
      userId: jsonSerialization['userId'] as String,
      displayName: jsonSerialization['displayName'] as String,
      color: jsonSerialization['color'] as String,
      textCursor: jsonSerialization['textCursor'] as int,
      isTyping: jsonSerialization['isTyping'] as bool,
      drawingX: (jsonSerialization['drawingX'] as num).toDouble(),
      drawingY: (jsonSerialization['drawingY'] as num).toDouble(),
      isDrawing: jsonSerialization['isDrawing'] as bool,
      lastActive: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActive'],
      ),
    );
  }

  /// Unique user identifier (generated client-side)
  String userId;

  /// Display name (optional, auto-generated if not provided)
  String displayName;

  /// User's assigned color (hex, e.g. "#FF5733")
  String color;

  /// Text cursor position (character offset), -1 = not editing text
  int textCursor;

  /// Whether user is actively typing
  bool isTyping;

  /// Drawing cursor position X (canvas coordinates), -1 = not drawing
  double drawingX;

  /// Drawing cursor position Y
  double drawingY;

  /// Whether user is actively drawing
  bool isDrawing;

  /// Last activity timestamp
  DateTime lastActive;

  /// Returns a shallow copy of this [UserPresence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserPresence copyWith({
    String? userId,
    String? displayName,
    String? color,
    int? textCursor,
    bool? isTyping,
    double? drawingX,
    double? drawingY,
    bool? isDrawing,
    DateTime? lastActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserPresence',
      'userId': userId,
      'displayName': displayName,
      'color': color,
      'textCursor': textCursor,
      'isTyping': isTyping,
      'drawingX': drawingX,
      'drawingY': drawingY,
      'isDrawing': isDrawing,
      'lastActive': lastActive.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UserPresenceImpl extends UserPresence {
  _UserPresenceImpl({
    required String userId,
    required String displayName,
    required String color,
    required int textCursor,
    required bool isTyping,
    required double drawingX,
    required double drawingY,
    required bool isDrawing,
    required DateTime lastActive,
  }) : super._(
         userId: userId,
         displayName: displayName,
         color: color,
         textCursor: textCursor,
         isTyping: isTyping,
         drawingX: drawingX,
         drawingY: drawingY,
         isDrawing: isDrawing,
         lastActive: lastActive,
       );

  /// Returns a shallow copy of this [UserPresence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserPresence copyWith({
    String? userId,
    String? displayName,
    String? color,
    int? textCursor,
    bool? isTyping,
    double? drawingX,
    double? drawingY,
    bool? isDrawing,
    DateTime? lastActive,
  }) {
    return UserPresence(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      color: color ?? this.color,
      textCursor: textCursor ?? this.textCursor,
      isTyping: isTyping ?? this.isTyping,
      drawingX: drawingX ?? this.drawingX,
      drawingY: drawingY ?? this.drawingY,
      isDrawing: isDrawing ?? this.isDrawing,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
