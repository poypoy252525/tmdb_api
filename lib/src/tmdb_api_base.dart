// TODO: Put public facing types in this file.

/// Exception thrown for TMDB API request failures.
class TmdbException implements Exception {
  /// HTTP status code, if available.
  final int? statusCode;

  /// Human-readable message.
  final String message;

  /// Raw response body, if available.
  final String? body;

  TmdbException({this.statusCode, required this.message, this.body});

  @override
  String toString() {
    final code = statusCode != null ? ' (status: $statusCode)' : '';
    return 'TmdbException$code: $message';
  }
}
