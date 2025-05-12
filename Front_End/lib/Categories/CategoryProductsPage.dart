import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryProductsPage extends StatefulWidget {
  final String category;

  const CategoryProductsPage({Key? key, required this.category})
    : super(key: key);

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.88.100:5000/api/products/category/${Uri.encodeComponent(widget.category)}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String getProductImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://placehold.co/300x300?text=No+Image';
    }
    if (imagePath.startsWith('/uploads/')) {
      return 'http://192.168.88.100:5000$imagePath';
    }
    return 'http://192.168.88.100:5000/uploads/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFF6F61EF)),
              )
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : products.isEmpty
              ? Center(child: Text('No products found in this category'))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final imageUrl = getProductImageUrl(product['image']);
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Icon(Icons.broken_image),
                        ),
                      ),
                      title: Text(product['name'] ?? 'Unnamed Product'),
                      subtitle: Text('${product['price'] ?? '0'} EGP'),
                    ),
                  );
                },
              ),
    );
  }
}
