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

/// Real-time transcript update from butler (not stored in database)
abstract class TranscriptUpdate implements _i1.SerializableModel {
  TranscriptUpdate._({
    required this.text,
    required this.timestamp,
  });

  factory TranscriptUpdate({
    required String text,
    required DateTime timestamp,
  }) = _TranscriptUpdateImpl;

  factory TranscriptUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return TranscriptUpdate(
      text: jsonSerialization['text'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  /// New transcript text
  String text;

  /// Timestamp of transcription
  DateTime timestamp;

  /// Returns a shallow copy of this [TranscriptUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TranscriptUpdate copyWith({
    String? text,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TranscriptUpdate',
      'text': text,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TranscriptUpdateImpl extends TranscriptUpdate {
  _TranscriptUpdateImpl({
    required String text,
    required DateTime timestamp,
  }) : super._(
         text: text,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [TranscriptUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TranscriptUpdate copyWith({
    String? text,
    DateTime? timestamp,
  }) {
    return TranscriptUpdate(
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
