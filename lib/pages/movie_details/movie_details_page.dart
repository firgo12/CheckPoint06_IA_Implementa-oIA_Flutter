import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/models/movie_result_model.dart';
import 'package:movie_app/pages/home/widgets/movies_horizontal_list.dart';
import 'package:movie_app/pages/movie_details/widgets/movie_details_item.dart';
import 'package:movie_app/services/api_services.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Future<Movie> movieDetailFuture;
  late Future<MoviesResult> movieRecommendationsFuture;

  @override
  void initState() {
    movieDetailFuture = ApiServices().getMovieDetails(widget.movie.id);
    movieRecommendationsFuture =
        ApiServices().getMovieRecommendations(widget.movie.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/movie_background3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<Movie>(
                  future: movieDetailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.hasData) {
                      final movie = snapshot.data!;
                      return MovieDetailsItem(movie: movie);
                    }
                    return const Center(child: Text('No data found'));
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recommendations',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<MoviesResult>(
                  future: movieRecommendationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.hasData) {
                      final recommendations = snapshot.data!;
                      return MoviesHorizontalList(
                        movies: recommendations.movies,
                        onTap: (movie) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsPage(movie: movie),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No data found'));
                  },
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
