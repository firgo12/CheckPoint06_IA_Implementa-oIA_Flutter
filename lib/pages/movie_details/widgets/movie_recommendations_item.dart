import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/home/widgets/movie_horizontal_item.dart';

class MovieRecommendationsItem extends StatelessWidget {
  final Movie movie;
  final void Function(Movie movie) onTap;

  const MovieRecommendationsItem({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MovieHorizontalItem(movie: movie, onTap: onTap);
  }
}
