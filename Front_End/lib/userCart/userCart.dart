import 'package:cadeau_project/Categories/ListCategories.dart';
import 'package:cadeau_project/User_Profile/user_profile.dart';
import 'package:cadeau_project/checkout_process/giftbox_webview.dart';
import 'package:cadeau_project/checkout_process/move_to_checkout_and_pay.dart';
import 'package:cadeau_project/home_page_payment.dart';
import 'package:cadeau_project/chosing_card_images/choosing_Card_for_Gift.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';
import '/custom/theme.dart';
import '/custom/icon_button.dart';
import '/custom/util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

import 'userCart_model.dart';
export 'userCart_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cadeau_project/models/userCart_model.dart';

class CartWidget extends StatefulWidget {
  final String userId;

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
          _cartFuture = _fetchCart();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from cart'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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
          _cartFuture = _fetchCart();
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor:
            FlutterFlowTheme.of(context)?.secondaryBackground ?? Colors.white,
        appBar: AppBar(
          backgroundColor:
              FlutterFlowTheme.of(context)?.secondaryBackground ?? Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'My Shopping Cart',
            style: FlutterFlowTheme.of(context)?.headlineMedium?.copyWith(
              color: Colors.black ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.shopping_cart_checkout_rounded,
                color: Colors.black ?? Colors.blue,
                size: 28,
              ),
            ),
          ],
        ),
        body: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white ?? Colors.blue,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: FlutterFlowTheme.of(context)?.error ?? Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style:
                          FlutterFlowTheme.of(context)?.headlineSmall ??
                          TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context)?.bodyMedium ??
                          TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final cart = snapshot.data!;
              final subtotal = cart.items.fold(
                0.0,
                (double sum, item) =>
                    sum + ((item.product.price ?? 0) * item.quantity),
              );
              final shipping = 5.99;
              final total = subtotal + shipping;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child:
                          cart.items.isEmpty
                              ? _buildEmptyCart()
                              : ListView.separated(
                                padding: EdgeInsets.only(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                itemCount: cart.items.length,
                                separatorBuilder:
                                    (context, index) => SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return _buildCartItem(item);
                                },
                              ),
                    ),
                    if (cart.items.isNotEmpty)
                      _buildCheckoutCard(
                        subtotal,
                        shipping,
                        total,
                        snapshot.data!.items,
                      ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  'No data available',
                  style:
                      FlutterFlowTheme.of(context)?.bodyLarge ??
                      TextStyle(fontSize: 16),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    nextPage = Profile16SimpleProfileWidget(
                      userId: widget.userId,
                    );
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
              backgroundColor: Colors.white,
              selectedItemColor: Color.fromARGB(255, 124, 177, 255),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: FlutterFlowTheme.of(context)?.secondaryText ?? Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: FlutterFlowTheme.of(context)?.headlineSmall?.copyWith(
              color: FlutterFlowTheme.of(context)?.secondaryText ?? Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Looks like you haven\'t added any items to your cart yet. Start shopping to fill it up!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context)?.bodyMedium?.copyWith(
                color:
                    FlutterFlowTheme.of(context)?.secondaryText ?? Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => userHomePage(userId: widget.userId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Color.fromARGB(255, 124, 177, 255) ?? Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    FlutterFlowTheme.of(context)?.titleMedium?.fontSize ?? 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 124, 177, 255) ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              item.product.imageUrls.isNotEmpty
                  ? item.product.imageUrls[0]
                  : 'https://via.placeholder.com/150',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color:
                        FlutterFlowTheme.of(context)?.alternate ??
                        Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color:
                          FlutterFlowTheme.of(context)?.secondaryText ??
                          Colors.grey,
                    ),
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name ?? 'Unnamed Product',
                    style: FlutterFlowTheme.of(
                      context,
                    )?.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${(item.product.price ?? 0).toStringAsFixed(2)}',
                    style: FlutterFlowTheme.of(context)?.bodyMedium?.copyWith(
                      color:
                          FlutterFlowTheme.of(context)?.primary ?? Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                FlutterFlowTheme.of(context)?.alternate ??
                                Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color:
                                    FlutterFlowTheme.of(context)?.primaryText ??
                                    Colors.black,
                              ),
                              onPressed:
                                  item.quantity > 1
                                      ? () => _updateQuantity(
                                        item.product.id,
                                        item.quantity - 1,
                                      )
                                      : null,
                            ),
                            Text(
                              '${item.quantity}',
                              style: FlutterFlowTheme.of(context)?.bodyMedium,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 18,
                                color:
                                    FlutterFlowTheme.of(context)?.primaryText ??
                                    Colors.black,
                              ),
                              onPressed:
                                  () => _updateQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color:
                              FlutterFlowTheme.of(context)?.error ?? Colors.red,
                        ),
                        onPressed: () => _removeItem(item.product.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard(
    double subtotal,
    double shipping,
    double total,
    List<CartItem> cartItems,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            FlutterFlowTheme.of(context)?.secondaryBackground ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: FlutterFlowTheme.of(context)?.bodyMedium),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: FlutterFlowTheme.of(context)?.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: FlutterFlowTheme.of(context)?.bodyMedium),
              Text(
                '\$${shipping.toStringAsFixed(2)}',
                style: FlutterFlowTheme.of(context)?.bodyMedium,
              ),
            ],
          ),
          Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: FlutterFlowTheme.of(
                  context,
                )?.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: FlutterFlowTheme.of(context)?.headlineSmall?.copyWith(
                  color: FlutterFlowTheme.of(context)?.primary ?? Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GiftBoxWebView(
                        userId: widget.userId,
                        cartItems: cartItems, // Pass cart items
                        subtotal: subtotal,
                        shipping: shipping,
                        total: total,
                      ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Color.fromARGB(255, 124, 177, 255) ?? Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Choose your gift box',
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    FlutterFlowTheme.of(context)?.titleMedium?.fontSize ?? 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
