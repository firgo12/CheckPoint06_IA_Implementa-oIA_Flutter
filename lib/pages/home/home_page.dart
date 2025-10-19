import 'package:flutter/material.dart';
import 'package:movie_app/models/movie_result_model.dart';
import 'package:movie_app/pages/home/widgets/movies_horizontal_list.dart';
import 'package:movie_app/pages/home/widgets/nowplaying_list.dart';
import 'package:movie_app/pages/movie_details/movie_details_page.dart';
import 'package:movie_app/services/api_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiServices apiServices = ApiServices();
  late Future<MoviesResult> popular;
  late Future<MoviesResult> nowPlaying;
  late Future<MoviesResult> upcoming;

  @override
  void initState() {
    popular = apiServices.getPopularMovies();
    nowPlaying = apiServices.getNowPlayingMovies();
    upcoming = apiServices.getUpcomingMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie App'),
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'images/movie_background3.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FutureBuilder<MoviesResult>(
                    future: nowPlaying,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      if (snapshot.hasData) {
                        final movies = snapshot.data!.movies;
                        return NowPlayingList(
                          movies: movies,
                          onTap: (movie) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsPage(
                                  movie: movie,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('No data found'),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      'Popular',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FutureBuilder<MoviesResult>(
                    future: popular,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      if (snapshot.hasData) {
                        return MoviesHorizontalList(
                          movies: snapshot.data!.movies,
                          onTap: (movie) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsPage(
                                  movie: movie,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('No data found'),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FutureBuilder<MoviesResult>(
                    future: upcoming,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      if (snapshot.hasData) {
                        return MoviesHorizontalList(
                          movies: snapshot.data!.movies,
                          onTap: (movie) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsPage(
                                  movie: movie,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('No data found'),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
