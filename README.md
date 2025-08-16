# TMDB API

A comprehensive Dart package for interacting with The Movie Database (TMDB) API. This package provides a clean, type-safe interface for fetching movie and TV show data from TMDB.

## Features

- 🎬 **Movies**: Search, get popular/top-rated movies, and fetch detailed movie information
- 📺 **TV Shows**: Search, get popular/top-rated TV shows, and fetch detailed TV show information
- 🌍 **Internationalization**: Support for multiple languages and regions
- 📄 **Pagination**: Built-in pagination support for list endpoints
- ⚡ **Type Safety**: Strongly typed models for all API responses
- 🔧 **Configurable**: Customizable timeout, HTTP client, and default settings
- 🛡️ **Error Handling**: Comprehensive error handling with custom exceptions

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  tmdb_api_kit: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Setup

### 1. Get TMDB API Access Token

1. Create an account at [The Movie Database](https://www.themoviedb.org/)
2. Go to your account settings → API
3. Create a new API key
4. Copy your **Bearer Token** (not the API key)

### 2. Environment Setup

For security, store your token as an environment variable:

```bash
# Linux/macOS
export TMDB_BEARER_TOKEN="your_bearer_token_here"

# Windows
set TMDB_BEARER_TOKEN=your_bearer_token_here
```

## Quick Start

```dart
import 'dart:io';
import 'package:tmdb_api_kit/tmdb_api_kit.dart';

Future<void> main() async {
  // Get token from environment variable
  final token = Platform.environment['TMDB_BEARER_TOKEN'];
  if (token == null) {
    print('Please set TMDB_BEARER_TOKEN environment variable');
    return;
  }

  // Create TMDB client
  final tmdb = Tmdb(token);

  try {
    // Get popular movies
    final popular = await tmdb.getPopularMovies(page: 1);
    print('Popular Movies:');
    for (final movie in popular.results.take(5)) {
      print('${movie.title} (${movie.releaseDate?.year ?? 'N/A'})');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    // Always dispose the client
    tmdb.dispose();
  }
}
```

## API Reference

### Constructor

```dart
Tmdb(
  String bearerToken, {
  Client? client,                    // Custom HTTP client
  Duration timeout = const Duration(seconds: 15),
  String? defaultLanguage,           // e.g., 'en-US', 'es-ES'
  String? defaultRegion,            // e.g., 'US', 'GB'
})
```

#### Defaults and overrides
- `defaultLanguage` and `defaultRegion` are applied automatically unless you pass `language`/`region` to a method.
- `timeout` applies per-request.
- If you pass a custom `http.Client`, it will be closed when you call `tmdb.dispose()`. Avoid reusing it elsewhere after disposing.

### Movies

#### Get Popular Movies
```dart
Future<PaginatedResponse<MovieSummaryModel>> getPopularMovies({
  int page = 1,
  String? language,
})
```

#### Get Top Rated Movies
```dart
Future<PaginatedResponse<MovieSummaryModel>> getTopRatedMovies({
  int page = 1,
  String? language,
})
```

#### Search Movies
```dart
Future<PaginatedResponse<MovieSummaryModel>> searchMovies({
  required String query,
  int page = 1,
  String? language,
  bool includeAdult = false,
  String? region,
  int? year,
  int? primaryReleaseYear,
})
```

#### Get Movie Details
```dart
Future<MovieDetailsModel> getMovieDetails({
  required int id,
  String? language,
})
```

### TV Shows

#### Get Popular TV Shows
```dart
Future<PaginatedResponse<TVShowSummaryModel>> getPopularTVShows({
  int page = 1,
  String? language,
})
```

#### Get Top Rated TV Shows
```dart
Future<PaginatedResponse<TVShowSummaryModel>> getTopRatedTVShows({
  int page = 1,
  String? language,
})
```

#### Search TV Shows
```dart
Future<PaginatedResponse<TVShowSummaryModel>> searchTVShows({
  required String query,
  int page = 1,
  String? language,
  bool includeAdult = false,
  int? firstAirDateYear,
})
```

#### Get TV Show Details
```dart
Future<TvShowDetailsModel> getTVShowDetails({
  required int id,
  String? language,
})
```

## Usage Examples

### Search for Movies

```dart
final tmdb = Tmdb(token);

try {
  final results = await tmdb.searchMovies(
    query: 'Inception',
    year: 2010,
    language: 'en-US',
  );
  
  print('Found ${results.totalResults} movies');
  for (final movie in results.results) {
    print('${movie.title} - Rating: ${movie.voteAverage}/10');
  }
} finally {
  tmdb.dispose();
}
```

### Get Movie Details

```dart
final tmdb = Tmdb(token);

try {
  final movie = await tmdb.getMovieDetails(id: 27205); // Inception
  print('Title: ${movie.title}');
  print('Overview: ${movie.overview}');
  print('Runtime: ${movie.runtime} minutes');
  print('Genres: ${movie.genres?.map((g) => g.name).join(', ')}');
} finally {
  tmdb.dispose();
}
```

### Search for TV Shows

```dart
final tmdb = Tmdb(token);

try {
  final results = await tmdb.searchTVShows(
    query: 'Breaking Bad',
    firstAirDateYear: 2008,
    language: 'en-US',
  );
  
  print('Found ${results.totalResults} shows');
  for (final show in results.results) {
    print('${show.name} - Rating: ${show.voteAverage}/10');
  }
} finally {
  tmdb.dispose();
}
```

### Get TV Show Details

```dart
final tmdb = Tmdb(token);

try {
  final show = await tmdb.getTVShowDetails(id: 1396); // Breaking Bad
  print('Name: ${show.name}');
  print('Overview: ${show.overview}');
  print('Seasons: ${show.numberOfSeasons}');
} finally {
  tmdb.dispose();
}
```

### Pagination Example
  
```dart
final tmdb = Tmdb(token);

try {
  int page = 1;
  List<MovieSummaryModel> allMovies = [];

  while (page <= 3) { // Get first 3 pages
    final response = await tmdb.getPopularMovies(page: page);
    allMovies.addAll(response.results);
    page++;
  }

  print('Retrieved ${allMovies.length} movies');
} finally {
  tmdb.dispose();
}
```

### With Custom Configuration

```dart
final tmdb = Tmdb(
  token,
  timeout: const Duration(seconds: 30),
  defaultLanguage: 'es-ES',  // Spanish
  defaultRegion: 'ES',       // Spain
);

// All requests will use Spanish language by default
final movies = await tmdb.getPopularMovies();
```

## Data Models

### MovieSummaryModel
Contains basic movie information returned by list endpoints:
- `id`, `title`, `originalTitle`
- `overview`, `releaseDate`
- `voteAverage`, `voteCount`, `popularity`
- `posterPath`, `backdropPath`
- `genreIds`, `adult`, `video`

### MovieDetailsModel
Extended movie information with additional fields like:
- `runtime`, `budget`, `revenue`
- `genres`, `productionCompanies`
- `spokenLanguages`, `productionCountries`

### TVShowSummaryModel & TvShowDetailsModel
Similar structure for TV shows with fields like:
- `name`, `originalName`, `firstAirDate`
- `episodeRunTime`, `numberOfSeasons`, `numberOfEpisodes`

### PaginatedResponse<T>
Wrapper for paginated API responses:
- `page`, `totalPages`, `totalResults`
- `results` - Array of items
 
Note: Pagination is 1-based. The first page is 1.

## Error Handling

The package throws `TmdbException` for API errors:

```dart
try {
  final movie = await tmdb.getMovieDetails(id: 999999);
} on TmdbException catch (e) {
  print('TMDB Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  print('Response Body: ${e.body}');
} catch (e) {
  print('Other error: $e');
}
```

## Best Practices

1. **Always dispose**: Call `tmdb.dispose()` when done to close HTTP connections
2. **Environment variables**: Store API tokens securely, never hardcode them
3. **Error handling**: Wrap API calls in try-catch blocks
4. **Rate limiting**: Be mindful of TMDB's rate limits (40 requests per 10 seconds)
5. **Caching**: Consider caching responses for better performance
6. **Pagination**: Use pagination for large result sets

## Testing

Run the included tests:

```bash
# Set your token first
export TMDB_BEARER_TOKEN="your_token_here"

# Run tests
dart test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This package is not officially associated with The Movie Database. TMDB is a trademark of The Movie Database.