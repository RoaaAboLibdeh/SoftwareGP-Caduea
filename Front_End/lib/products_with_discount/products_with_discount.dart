import 'package:cadeau_project/models/product_model.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:cadeau_project/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductsWithDiscountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Discounted Products")),
      backgroundColor: Color(0xFFF1F4F8),
      body: FutureBuilder<List<Product>>(
        future: ProductService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found'));
          } else {
            final discountedProducts =
                snapshot.data!
                    .where(
                      (p) => p.discountAmount != null && p.discountAmount! > 0,
                    )
                    .toList();

            if (discountedProducts.isEmpty) {
              return Center(child: Text('No discounted products available'));
            }

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 44),
              primary: false,
              shrinkWrap: true,
              itemCount: (discountedProducts.length / 2).ceil(),
              itemBuilder: (context, index) {
                final firstIndex = index * 2;
                final secondIndex = firstIndex + 1;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (firstIndex < discountedProducts.length)
                        Expanded(
                          child: _buildSmallProductCard(
                            context: context,
                            product: discountedProducts[firstIndex],
                          ),
                        ),
                      SizedBox(width: 8),
                      if (secondIndex < discountedProducts.length)
                        Expanded(
                          child: _buildSmallProductCard(
                            context: context,
                            product: discountedProducts[secondIndex],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsWidget(product: product),
          ),
        );
      },
      child: Stack(
        children: [
          // Card UI
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.imageUrls.isNotEmpty
                        ? product.imageUrls[0]
                        : 'https://via.placeholder.com/150',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
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
                print('Add ${product.name}');
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
    );
  }
}
