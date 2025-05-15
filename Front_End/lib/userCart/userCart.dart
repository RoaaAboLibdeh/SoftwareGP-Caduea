import 'package:cadeau_project/Categories/ListCategories.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';
import '/custom/theme.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'userCart_model.dart';
export 'userCart_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cadeau_project/models/userCart_model.dart';

class CartWidget extends StatefulWidget {
  final String userId; // Add userId parameter

  const CartWidget({super.key, required this.userId});

  static String routeName = 'cart';
  static String routePath = '/cart';

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;
  late Future<Cart> _cartFuture;
  int _currentIndex = 2;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
    _cartFuture = _fetchCart();
  }

  Future<Cart> _fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.100:5000/api/cart/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Cart API status: ${response.statusCode}');
      print('Cart API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded cart data: $data');
        return Cart.fromJson(data);
      } else if (response.statusCode == 404) {
        // Handle empty cart case
        return Cart(
          userId: widget.userId,
          items: [],
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _fetchCart: $e');
      throw e;
    }
  }

  Future<void> _removeItem(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.88.100:5000/api/cart/remove'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId, 'productId': productId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _cartFuture = _fetchCart(); // Refresh cart
        });
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.88.100:5000/api/cart/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'productId': productId,
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _cartFuture = _fetchCart(); // Refresh cart
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // ... (keep bottom navigation and other existing code)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'My Cart',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
        ),
        body: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Error details: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 50),
                    SizedBox(height: 16),
                    Text('Failed to load cart', style: TextStyle(fontSize: 18)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _cartFuture = _fetchCart();
                        });
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasData) {
              final cart = snapshot.data!;
              if (cart.items.isEmpty) {
                return Center(child: Text('Your cart is empty.'));
              }

              return ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        (item.product.imageUrls.isNotEmpty
                            ? item.product.imageUrls[0]
                            : '')!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image),
                      ),
                      title: Text(item.product.name ?? 'No Name'),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${item.product.price.toStringAsFixed(2)}'),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeItem(item.product.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            // ✅ Final fallback return
            return Center(child: Text('No cart data available.'));
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    double value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal
                    ? FlutterFlowTheme.of(context).bodyLarge
                    : FlutterFlowTheme.of(context).labelMedium,
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style:
                isTotal
                    ? FlutterFlowTheme.of(context).displaySmall.override(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    )
                    : FlutterFlowTheme.of(context).bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;
            setState(() => _currentIndex = index);

            Widget nextPage;
            switch (index) {
              case 0:
                nextPage = userHomePage(userId: widget.userId);
                break;
              case 1:
                nextPage = CategoriesPage(userId: widget.userId);
                break;
              case 2:
                nextPage = CartWidget(userId: widget.userId);
                break;
              case 3:
                nextPage = CartWidget(userId: widget.userId); // Replace later
                break;
              default:
                return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nextPage),
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: FlutterFlowTheme.of(context).primary,
          unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
          selectedLabelStyle: FlutterFlowTheme.of(context).titleSmall,
          unselectedLabelStyle: FlutterFlowTheme.of(context).labelSmall,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
          ],
        ),
      ),
    );
  }
}
