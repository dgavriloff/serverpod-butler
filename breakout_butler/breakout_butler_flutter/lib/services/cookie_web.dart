import 'package:web/web.dart' as web;

/// Simple browser cookie helper for Flutter web.
class CookieService {
  /// Set a cookie with the given name and value.
  /// Defaults to 7-day expiry, path=/, SameSite=Strict.
  static void set(String name, String value, {int maxAgeDays = 7}) {
    final maxAge = maxAgeDays * 86400;
    web.document.cookie = '$name=$value; path=/; max-age=$maxAge; SameSite=Strict';
  }

  /// Get a cookie value by name. Returns null if not found.
  static String? get(String name) {
    final cookies = web.document.cookie;
    if (cookies.isEmpty) return null;
    for (final cookie in cookies.split('; ')) {
      final parts = cookie.split('=');
      if (parts.length == 2 && parts[0] == name) {
        return parts[1];
      }
    }
    return null;
  }

  /// Delete a cookie by setting its max-age to 0.
  static void delete(String name) {
    web.document.cookie = '$name=; path=/; max-age=0';
  }
}
