// lib/models/product_model.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountAmount;
  final List<String> imageUrls;
  final List<String> recipientType;
  final List<String> occasion;
  final int stock;
  final bool isOnSale;
  final String category; // Add this line

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountAmount,
    required this.imageUrls,
    required this.recipientType,
    required this.occasion,
    required this.stock,
    this.isOnSale = false,
    required this.category, // Add this line
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['productId'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount']?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      recipientType: List<String>.from(json['recipientType'] ?? []),
      occasion: List<String>.from(json['occasion'] ?? []),
      stock: json['stock'] ?? 0,
      isOnSale: json['isOnSale'] ?? false,
      category: _parseCategory(json['category']),
    );
  }

  static String _parseCategory(dynamic category) {
    if (category is String) return category;
    if (category is Map) return category['_id'] ?? category['id'] ?? '';
    return '';
  }

  double get discountedPrice =>
      discountAmount != null ? price - discountAmount! : price;
}
