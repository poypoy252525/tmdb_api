import 'dart:io';
import 'package:tmdb_api_kit/tmdb_api_kit.dart';

Future<void> main() async {
  final token = Platform.environment['TMDB_BEARER_TOKEN'];
  if (token == null) {
    print('Set TMDB_BEARER_TOKEN to try the example.');
    return;
  }

  final tmdb = Tmdb(token);
  try {
    final popular = await tmdb.getPopularMovies(page: 1);
    for (final m in popular.results.take(3)) {
      print('${m.title} (${m.releaseDate?.year ?? 'n/a'})');
    }
  } finally {
    tmdb.dispose();
  }
}
