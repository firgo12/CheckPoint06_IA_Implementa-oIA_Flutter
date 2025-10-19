import 'dart:convert';

import 'package:movie_app/models/movie_model.dart';

class MoviesResult {
  int page;
  List<Movie> movies;
  int totalPages;
  int totalResults;

  MoviesResult({
    required this.page,
    required this.movies,
    required this.totalPages,
    required this.totalResults,
  });

  factory MoviesResult.fromRawJson(String str) =>
      MoviesResult.fromJson(json.decode(str));

  factory MoviesResult.fromJson(Map<String, dynamic> json) => MoviesResult(
        page: json["page"],
        movies: List<Movie>.from(json["results"].map((x) => Movie.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}
