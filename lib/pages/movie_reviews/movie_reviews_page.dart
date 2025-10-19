import 'package:flutter/material.dart';
import 'package:movie_app/models/review_result_model.dart';
import 'package:movie_app/pages/movie_reviews/widgets/movie_reviews_item.dart';
import 'package:movie_app/services/api_services.dart';

class MovieReviewsPage extends StatefulWidget {
  final int movieId;

  const MovieReviewsPage({super.key, required this.movieId});

  @override
  State<MovieReviewsPage> createState() => _MovieReviewsPageState();
}

class _MovieReviewsPageState extends State<MovieReviewsPage> {
  late Future<ReviewsResult> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ApiServices().getMovieReviews(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: FutureBuilder<ReviewsResult>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final reviews = snapshot.data!.results;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];

                return MovieReviewsItem(
                  review: review,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieReviewsItem(
                          review: review,
                          onTap: () {},
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No data found'));
        },
      ),
    );
  }
}
