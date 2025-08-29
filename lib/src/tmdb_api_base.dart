export 'models/movie_details_model.dart';
export 'models/movie_summary_model.dart';
export 'models/popular_movie_response.dart';
export 'models/tv_show_summary_model.dart';
// TODO: Remove the duplicates instead of hiding them
export 'models/tv_show_details_model.dart' hide Genre, ProductionCountry, SpokenLanguage;

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
