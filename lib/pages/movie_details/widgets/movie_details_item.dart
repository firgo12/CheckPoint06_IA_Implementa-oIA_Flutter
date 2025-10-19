import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/pages/movie_reviews/movie_reviews_page.dart';
import 'package:movie_app/widgets/custom_genres_label.dart';

class MovieDetailsItem extends StatelessWidget {
  final Movie movie;

  const MovieDetailsItem({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Image.network(
              '$imageUrl${movie.posterPath}',
              height: 230,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            movie.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Release Date:  ${DateFormat("MMM d',' y").format(movie.releaseDate!)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 15),
              Text(
                ' Runtime: ${movie.runtime} minutes',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.yellow,
                size: 15,
              ),
              Text(
                ' Rating: ${movie.voteAverage.toStringAsFixed(1)} / 10',
                style: const TextStyle(color: Colors.yellow),
              ),
              const SizedBox(width: 15.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieReviewsPage(movieId: movie.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white54,
                  ),
                  child: const Text(
                    'View Reviews',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8.0,
            runSpacing: 1.0,
            children: movie.genres.map((genre) {
              return GenresLabel(
                genreName: genre.name,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            movie.overview,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
