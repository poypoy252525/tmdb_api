import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:tmdb_api/src/models/movie_details_model.dart';
import 'package:tmdb_api/src/models/movie_summary_model.dart';
import 'package:tmdb_api/src/models/popular_movie_response.dart';
import 'package:tmdb_api/src/models/tv_show_summary_model.dart';
import 'package:tmdb_api/src/models/tv_show_details_model.dart';
import 'package:tmdb_api/src/tmdb_api_base.dart';

class Tmdb {
  // HTTP and config
  late final Client _client;
  final String _apiKey;
  late final Map<String, String> _headers;
  final String _baseUrl = 'https://api.themoviedb.org';
  late final Duration _timeout;
  late final String? _defaultLanguage;
  late final String? _defaultRegion;

  Tmdb(
    this._apiKey, {
    Client? client,
    Duration timeout = const Duration(seconds: 15),
    String? defaultLanguage,
    String? defaultRegion,
  }) {
    _client = client ?? Client();
    _timeout = timeout;
    _defaultLanguage = defaultLanguage;
    _defaultRegion = defaultRegion;
    _headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  Uri _buildUri(String endpoint, Map<String, String?> query) {
    final qp = <String, String>{};
    // include defaults when not overridden
    if ((_defaultLanguage ?? '').isNotEmpty && (query['language'] == null)) {
      qp['language'] = _defaultLanguage!;
    }
    if ((_defaultRegion ?? '').isNotEmpty && (query['region'] == null)) {
      qp['region'] = _defaultRegion!;
    }
    // provided params
    query.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        qp[key] = value;
      }
    });
    return Uri.parse('$_baseUrl$endpoint').replace(queryParameters: qp);
  }

  Future<Response> _get(Uri uri) async {
    try {
      return await _client.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw TmdbException(message: 'Request timed out: ${uri.path}');
    } catch (e) {
      throw TmdbException(message: 'Request failed: ${uri.path} ($e)');
    }
  }

  Never _throwFor(Response response) {
    String message = 'HTTP ${response.statusCode}';
    try {
      final body = jsonDecode(response.body);
      final statusMessage = body is Map<String, dynamic>
          ? (body['status_message']?.toString())
          : null;
      if (statusMessage != null && statusMessage.isNotEmpty) {
        message = statusMessage;
      }
    } catch (_) {
      // ignore parse errors
    }
    throw TmdbException(
      statusCode: response.statusCode,
      message: message,
      body: response.body,
    );
  }

  Future<PaginatedResponse<T>> _getMediaList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    int page = 1,
    String? language,
    Map<String, String?> extraQuery = const {},
  }) async {
    final uri = _buildUri(endpoint, {
      'page': '$page',
      'language': language,
      ...extraQuery,
    });
    final response = await _get(uri);
    if (response.statusCode != 200) {
      _throwFor(response);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedResponse<T>.fromJson(body, fromJson);
  }

  Future<PaginatedResponse<MovieSummaryModel>> getPopularMovies({
    int page = 1,
    String? language,
  }) async {
    return _getMediaList<MovieSummaryModel>(
      endpoint: '/3/movie/popular',
      fromJson: MovieSummaryModel.fromJson,
      page: page,
      language: language,
    );
  }

  Future<PaginatedResponse<MovieSummaryModel>> getTopRatedMovies({
    int page = 1,
    String? language,
  }) async {
    return _getMediaList<MovieSummaryModel>(
      endpoint: '/3/movie/top_rated',
      fromJson: MovieSummaryModel.fromJson,
      page: page,
      language: language,
    );
  }

  /// Search movies by text query.
  /// Mirrors https://developer.themoviedb.org/reference/search-movie
  Future<PaginatedResponse<MovieSummaryModel>> searchMovies({
    required String query,
    int page = 1,
    String? language,
    bool includeAdult = false,
    String? region,
    int? year,
    int? primaryReleaseYear,
  }) async {
    return _getMediaList<MovieSummaryModel>(
      endpoint: '/3/search/movie',
      fromJson: MovieSummaryModel.fromJson,
      page: page,
      language: language,
      extraQuery: {
        'query': query,
        'include_adult': includeAdult ? 'true' : 'false',
        'region': region,
        if (year != null) 'year': year.toString(),
        if (primaryReleaseYear != null)
          'primary_release_year': primaryReleaseYear.toString(),
      },
    );
  }

  Future<MovieDetailsModel> getMovieDetails({
    required int id,
    String? language,
  }) async {
    final uri = _buildUri('/3/movie/$id', {'language': language});
    final response = await _get(uri);
    if (response.statusCode != 200) {
      _throwFor(response);
    }
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return MovieDetailsModel.fromJson(jsonMap);
  }

  Future<PaginatedResponse<TVShowSummaryModel>> getPopularTVShows({
    int page = 1,
    String? language,
  }) async {
    return _getMediaList(
      endpoint: '/3/tv/popular',
      fromJson: TVShowSummaryModel.fromJson,
      page: page,
      language: language,
    );
  }

  Future<PaginatedResponse<TVShowSummaryModel>> getTopRatedTVShows({
    int page = 1,
    String? language,
  }) async {
    return _getMediaList(
      endpoint: '/3/tv/top_rated',
      fromJson: TVShowSummaryModel.fromJson,
      page: page,
      language: language,
    );
  }

  /// Search TV series by text query.
  /// Mirrors https://developer.themoviedb.org/reference/search-tv
  Future<PaginatedResponse<TVShowSummaryModel>> searchTVShows({
    required String query,
    int page = 1,
    String? language,
    bool includeAdult = false,
    int? firstAirDateYear,
  }) async {
    return _getMediaList<TVShowSummaryModel>(
      endpoint: '/3/search/tv',
      fromJson: TVShowSummaryModel.fromJson,
      page: page,
      language: language,
      extraQuery: {
        'query': query,
        'include_adult': includeAdult ? 'true' : 'false',
        if (firstAirDateYear != null)
          'first_air_date_year': firstAirDateYear.toString(),
      },
    );
  }

  Future<TvShowDetailsModel> getTVShowDetails({
    required int id,
    String? language,
  }) async {
    final uri = _buildUri('/3/tv/$id', {'language': language});
    final response = await _get(uri);
    if (response.statusCode != 200) {
      _throwFor(response);
    }
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return TvShowDetailsModel.fromJson(jsonMap);
  }

  void dispose() {
    _client.close();
  }
}
