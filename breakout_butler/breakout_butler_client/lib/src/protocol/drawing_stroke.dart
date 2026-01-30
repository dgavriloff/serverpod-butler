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

/// A single drawing stroke with unique ID for CRDT-style merging
abstract class DrawingStroke implements _i1.SerializableModel {
  DrawingStroke._({
    required this.id,
    required this.userId,
    required this.points,
    required this.color,
    required this.width,
    required this.createdAt,
    required this.deleted,
  });

  factory DrawingStroke({
    required String id,
    required String userId,
    required String points,
    required String color,
    required double width,
    required DateTime createdAt,
    required bool deleted,
  }) = _DrawingStrokeImpl;

  factory DrawingStroke.fromJson(Map<String, dynamic> jsonSerialization) {
    return DrawingStroke(
      id: jsonSerialization['id'] as String,
      userId: jsonSerialization['userId'] as String,
      points: jsonSerialization['points'] as String,
      color: jsonSerialization['color'] as String,
      width: (jsonSerialization['width'] as num).toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      deleted: jsonSerialization['deleted'] as bool,
    );
  }

  /// Unique stroke identifier (UUID)
  String id;

  /// User ID who drew this stroke
  String userId;

  /// Points as JSON array of [x, y, pressure] tuples
  String points;

  /// Stroke color (hex)
  String color;

  /// Stroke width
  double width;

  /// Timestamp when stroke was created
  DateTime createdAt;

  /// Whether stroke is deleted (soft delete for CRDT)
  bool deleted;

  /// Returns a shallow copy of this [DrawingStroke]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DrawingStroke copyWith({
    String? id,
    String? userId,
    String? points,
    String? color,
    double? width,
    DateTime? createdAt,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DrawingStroke',
      'id': id,
      'userId': userId,
      'points': points,
      'color': color,
      'width': width,
      'createdAt': createdAt.toJson(),
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DrawingStrokeImpl extends DrawingStroke {
  _DrawingStrokeImpl({
    required String id,
    required String userId,
    required String points,
    required String color,
    required double width,
    required DateTime createdAt,
    required bool deleted,
  }) : super._(
         id: id,
         userId: userId,
         points: points,
         color: color,
         width: width,
         createdAt: createdAt,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [DrawingStroke]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DrawingStroke copyWith({
    String? id,
    String? userId,
    String? points,
    String? color,
    double? width,
    DateTime? createdAt,
    bool? deleted,
  }) {
    return DrawingStroke(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      createdAt: createdAt ?? this.createdAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
