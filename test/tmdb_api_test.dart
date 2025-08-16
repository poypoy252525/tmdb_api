import 'package:tmdb_api/tmdb_api.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('A group of tests', () {
    final token = Platform.environment['TMDB_BEARER_TOKEN'];
    final tmdb = token == null ? null : Tmdb(token);

    setUp(() {
      // Additional setup goes here.
    });

    test(
      'API test popular TV shows',
      () async {
        final response = await tmdb!.getPopularTVShows();
        expect(response.results.isNotEmpty, isTrue);
      },
      skip: token == null
          ? 'Set TMDB_BEARER_TOKEN in env to run API tests'
          : false,
    );

    test(
      'API test TV show details',
      () async {
        // Using a known TV show id (e.g., 1399 for Game of Thrones)
        final details = await tmdb!.getTVShowDetails(id: 1399);
        expect(details.id, 1399);
        expect(details.name, isNotEmpty);
      },
      skip: token == null
          ? 'Set TMDB_BEARER_TOKEN in env to run API tests'
          : false,
    );

    test(
      'API search movies',
      () async {
        final response = await tmdb!.searchMovies(query: 'Inception', page: 1);
        expect(response.results, isNotEmpty);
      },
      skip: token == null
          ? 'Set TMDB_BEARER_TOKEN in env to run API tests'
          : false,
    );

    test(
      'API search TV shows',
      () async {
        final response = await tmdb!.searchTVShows(
          query: 'Breaking Bad',
          page: 1,
        );
        expect(response.results, isNotEmpty);
      },
      skip: token == null
          ? 'Set TMDB_BEARER_TOKEN in env to run API tests'
          : false,
    );

    tearDownAll(() {
      tmdb?.dispose();
    });
  });
}
