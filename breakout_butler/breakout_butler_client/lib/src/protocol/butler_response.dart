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

/// Response from the butler AI
abstract class ButlerResponse implements _i1.SerializableModel {
  ButlerResponse._({
    required this.answer,
    required this.success,
    this.error,
  });

  factory ButlerResponse({
    required String answer,
    required bool success,
    String? error,
  }) = _ButlerResponseImpl;

  factory ButlerResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ButlerResponse(
      answer: jsonSerialization['answer'] as String,
      success: jsonSerialization['success'] as bool,
      error: jsonSerialization['error'] as String?,
    );
  }

  /// The answer to the user's question
  String answer;

  /// Whether the response was successful
  bool success;

  /// Error message if not successful
  String? error;

  /// Returns a shallow copy of this [ButlerResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ButlerResponse copyWith({
    String? answer,
    bool? success,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ButlerResponse',
      'answer': answer,
      'success': success,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ButlerResponseImpl extends ButlerResponse {
  _ButlerResponseImpl({
    required String answer,
    required bool success,
    String? error,
  }) : super._(
         answer: answer,
         success: success,
         error: error,
       );

  /// Returns a shallow copy of this [ButlerResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ButlerResponse copyWith({
    String? answer,
    bool? success,
    Object? error = _Undefined,
  }) {
    return ButlerResponse(
      answer: answer ?? this.answer,
      success: success ?? this.success,
      error: error is String? ? error : this.error,
    );
  }
}
