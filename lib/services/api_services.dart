import 'dart:convert';

import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/movie_result_model.dart';
import 'package:movie_app/models/review_result_model.dart';

const baseUrl = 'https://api.themoviedb.org/3/';
const key = '?api_key=$apiKey';

class ApiServices {
  Future<ReviewsResult> getMovieReviews(int movieId) async {
    final endpoint = "movie/$movieId/reviews";
    final url = Uri.parse("$baseUrl$endpoint$key");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ReviewsResult.fromJson(json);
    }
    throw Exception('failed to load movie reviews');
  }

  Future<MoviesResult> getMovieRecommendations(int movieId) async {
    final endpoint = "movie/$movieId/recommendations";
    final url = Uri.parse("$baseUrl$endpoint$key");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return MoviesResult.fromJson(json);
    }
    throw Exception('failed to load movie recommendations');
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final endpoint = "movie/$movieId";
    final url = Uri.parse("$baseUrl$endpoint$key");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Movie.fromJson(json);
    }
    throw Exception('failed to load movie details');
  }

  Future<MoviesResult> getTopRatedMovies() async {
    var endPoint = 'movie/top_rated';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return MoviesResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('failed to load now playing movies');
  }

  Future<MoviesResult> getNowPlayingMovies() async {
    var endPoint = 'movie/now_playing';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return MoviesResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('failed to load now playing movies');
  }

  Future<MoviesResult> getUpcomingMovies() async {
    var endPoint = 'movie/upcoming';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return MoviesResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('failed to load upcoming movies');
  }

  Future<MoviesResult> getPopularMovies() async {
    const endPoint = 'movie/popular';
    const url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url), headers: {});
    if (response.statusCode == 200) {
      return MoviesResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('failed to load now playing movies');
  }
}
