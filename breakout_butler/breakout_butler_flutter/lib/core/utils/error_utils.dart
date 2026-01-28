import 'package:serverpod_client/serverpod_client.dart';

/// Extracts a user-friendly error message from any exception.
///
/// Strips Serverpod internals, class names, and stack traces so the UI
/// only shows clean, lowercase messages the user can act on.
String friendlyError(Object error) {
  if (error is ServerpodClientException) {
    return _parseServerpodMessage(error.message);
  }

  final raw = error.toString();

  // Strip common prefixes like "Exception: " or "ServerpodClientException: "
  final cleaned = raw
      .replaceFirst(RegExp(r'^[\w]+Exception:\s*'), '')
      .replaceFirst(RegExp(r',\s*statusCode\s*=\s*\d+$'), '')
      .trim();

  if (cleaned.isEmpty) {
    return 'something went wrong — please try again';
  }

  return _lowercaseFirst(cleaned);
}

String _parseServerpodMessage(String message) {
  // Serverpod internal server error wraps the original message.
  // The message is typically "Internal server error" for 500s,
  // but the actual throw message is embedded for custom exceptions.
  final lower = message.toLowerCase().trim();

  if (lower == 'internal server error' || lower.isEmpty) {
    return 'something went wrong — please try again';
  }

  return _lowercaseFirst(message.trim());
}

String _lowercaseFirst(String s) {
  if (s.isEmpty) return s;
  return s[0].toLowerCase() + s.substring(1);
}
