import 'package:cadeau_project/models/product_model.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryProductsPage extends StatefulWidget {
  final String category;
  final String categoryId;
  final String userId;
  const CategoryProductsPage({
    Key? key,
    required this.category,
    required this.categoryId,
    required this.userId,
  }) : super(key: key);

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
          'http://192.168.88.100:5000/api/products/category/${widget.categoryId}',
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
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = Product.fromJson(products[index]);
                          return _buildSmallProductCard(
                            context: context,
                            product: product,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSmallProductCard({
    required BuildContext context,
    required Product product,
  }) {
    final bool hasDiscount =
        product.isOnSale &&
        product.discountAmount != null &&
        product.discountAmount! > 0 &&
        product.price > 0;

    final int discountPercentage =
        hasDiscount
            ? ((product.discountAmount! / product.price) * 100).round()
            : 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailsWidget(
                    product: product,
                    userId: widget.userId,
                  ),
            ),
          );
        },
        child: Stack(
          children: [
            // Card UI
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Add this line
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image - Make this flexible
                  AspectRatio(
                    aspectRatio: 1, // Square image
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.imageUrls.isNotEmpty
                            ? product.imageUrls[0]
                            : 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Text content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Add this line
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        // Prices
                        hasDiscount
                            ? Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '\$${product.discountedPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Discount badge
            if (hasDiscount)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-$discountPercentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Add icon button
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductDetailsWidget(
                            product: product,
                            userId: widget.userId,
                          ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  child: Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
