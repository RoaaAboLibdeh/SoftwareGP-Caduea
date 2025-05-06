// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.88.100:5000/api';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
      throw Exception('Invalid data format');
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  static Future<Product> fetchProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        return Product.fromJson(data['data']);
      }
      throw Exception('Product not found');
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }
}
