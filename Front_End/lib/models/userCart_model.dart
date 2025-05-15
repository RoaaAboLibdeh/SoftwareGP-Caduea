import 'package:cadeau_project/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] ?? {}), // Handle null product
      quantity: json['quantity']?.toInt() ?? 1, // Ensure quantity is int
    );
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  Cart({required this.userId, required this.items, required this.updatedAt});

  factory Cart.fromJson(Map<String, dynamic> json) {
    // Handle case where items might be null or not a list
    List<CartItem> items = [];
    if (json['items'] is List) {
      items =
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item ?? {}))
              .toList();
    }

    return Cart(
      userId: json['user']?.toString() ?? '',
      items: items,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'].toString())
              : DateTime.now(),
    );
  }

  double get totalPrice {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.product.discountedPrice * item.quantity),
    );
  }
}
