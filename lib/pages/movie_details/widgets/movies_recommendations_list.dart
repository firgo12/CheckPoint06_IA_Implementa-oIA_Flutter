import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/home/widgets/movies_horizontal_list.dart';

class MoviesRecommendationsList extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie movie) onTap;
  const MoviesRecommendationsList(
      {super.key, required this.movies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MoviesHorizontalList(movies: movies, onTap: onTap);
  }
}
