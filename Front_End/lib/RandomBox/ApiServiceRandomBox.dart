import 'package:cadeau_project/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServiceRandomBox {
  final String baseUrl = 'http://192.168.88.100:5000';

  Future<List<Product>> getRandomBoxProducts({
    required int priceTier,
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/products/random-box?priceTier=$priceTier&userId=$userId',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
