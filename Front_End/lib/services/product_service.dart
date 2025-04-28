// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.88.14:5000/api/products'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['data'];
      return products.map<Product>((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
