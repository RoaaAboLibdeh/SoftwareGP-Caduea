import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';

class ReviewService {
  final String baseUrl =
      'http://192.168.88.100:5000/api/reviews'; // Replace with your real URL

  Future<List<Review>> fetchReviews(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/product/$productId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((reviewJson) => Review.fromJson(reviewJson)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
