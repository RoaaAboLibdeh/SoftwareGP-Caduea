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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountAmount,
    required this.imageUrls,
    required this.recipientType,
    required this.occasion,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['productId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      recipientType: List<String>.from(json['recipientType'] ?? []),
      occasion: List<String>.from(json['occasion'] ?? []),
    );
  }
}
