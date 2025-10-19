import 'package:movie_app/models/review_model.dart';

class ReviewsResult {
  final int id;
  final int page;
  final List<Review> results;
  final int totalPages;
  final int totalResults;

  ReviewsResult({
    required this.id,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory ReviewsResult.fromJson(Map<String, dynamic> json) {
    return ReviewsResult(
      id: json['id'],
      page: json['page'],
      results: List<Review>.from(
        json['results'].map((x) => Review.fromJson(x)),
      ),
      totalPages: json['total_pages'],
      totalResults: json['total_results'],
    );
  }
}
