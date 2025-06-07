import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/RandomBox/RandomBoxSelectionPage.dart';
import 'package:cadeau_project/User_Profile/user_profile.dart';
import 'package:cadeau_project/avatar_chat_page/avatar_chat_page.dart';
import 'package:cadeau_project/checkout_screen_map.dart/checkout_screen.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:cadeau_project/products_with_discount/products_with_discount.dart';
import 'package:cadeau_project/searchResults/searchResult.dart';
import 'package:cadeau_project/userCart/userCart.dart';
import 'package:cadeau_project/userHomePage/userHomePage_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter/material.dart';
export 'userHomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/Categories/ListCategories.dart';
import 'package:http/http.dart' as http;
import '/models/product_model.dart';
import '/services/product_service.dart';

class userHomePage extends StatefulWidget {
  final String userId;
  const userHomePage({super.key, required this.userId});

  @override
  State<userHomePage> createState() => _userHomePageState();
}

class _userHomePageState extends State<userHomePage> {
  int _currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  static const Map<String, String> avatarNames = {
    'ak': 'Alex',
    '3311bb6338d7888219': 'Mia',
    '4': 'Jordan',
    'jonny': 'Jonny',
    'vv': 'Vivian',
    'lm': 'Liam',
    '895llkb6': 'Emma',
    'pplo8851': 'Sophia',
    'pplo8c5': 'Noah',
    'pplo8r5': 'Marcos',
    'pplo8r53': 'Ethan',
    'pplo8r575': 'Ava',
    'p44fl8r5': 'Lucas',
    'ppl887568r5': 'Isabella',
    'ederfotfr': 'Jessy',
    'vcfrtg5o654m': 'GiGi',
    'qw3w244otr6tg': 'Moe',
    'bgtiyp56': 'Jacob',
    'mk88uh2go11': 'Joerge',
    '5g5t8y96fo3d': 'Alma',
    'roa': 'Jad',
    'banana1': 'Jenny',
    'helda23er': 'Welliam',
    'sarah1234': 'Fai',
  };
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.100:5000/api/users/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<List<Product>> fetchTopPopularProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.88.100:5000/api/products/popular?limit=10'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular products');
    }
  }

  void _navigateToAvatarChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AvatarChatPage(
              avatarCode: userData?['avatar'] ?? 'ak', // Original avatar code
              avatarName:
                  avatarNames[userData?['avatar']] ??
                  'Assistant', // Friendly name
              userId: widget.userId,
              userName: userData?['name'] ?? 'User',
            ),
      ),
    );
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final response = await http.get(
      Uri.parse('http://192.168.88.100:5000/api/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final results =
          (jsonDecode(response.body) as List)
              .map((json) => Product.fromJson(json))
              .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  SearchResultPage(products: results, userId: widget.userId),
        ),
      );
    }
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
    );
  }

  Widget _buildSpecialFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToAvatarChat(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6F61EF), Color(0x4D9489F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child:
                              isLoading
                                  ? Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                  : (userData?['avatar'] != null &&
                                      userData!['avatar'].isNotEmpty)
                                  ? AvatarPlus(
                                    userData!['avatar'],
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
                                    'https://picsum.photos/seed/626/600',
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hey ${isLoading ? '' : userData?['name'] ?? 'User'}!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      print('Notification tapped');
                    },
                  ),
                ],
              ),

              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            hintText: 'Search for products...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                          // onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: const Color.fromARGB(255, 31, 30, 30),
                        ),
                        onPressed: () => _performSearch(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                // Special Features Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      _buildSpecialFeatureButton(
                        icon: Icons.card_giftcard,
                        label: 'Random Box',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RandomBoxSelectionPage(
                                    userId: widget.userId,
                                  ),
                            ),
                          );
                        },
                      ),
                      _buildSpecialFeatureButton(
                        icon: Icons.coffee,
                        label: '3D Mugs',
                        color: Colors.orange,
                        onTap: () {
                          // Navigate to 3D mugs category
                        },
                      ),
                    ],
                  ),
                ),

                // Hero Banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summer Sale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Up to 50% off selected items',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProductsWithDiscountPage(
                                            userId: widget.userId,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6F61EF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Shop Now'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Popular Products Section
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Popular Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 4),
                FutureBuilder<List<Product>>(
                  future: fetchTopPopularProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No recommended products found.'),
                      );
                    }

                    final products = snapshot.data!;

                    return SizedBox(
                      height: 260,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder:
                            (context, index) => SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return SizedBox(
                            width: 160,
                            child: _buildSmallProductCard(
                              context: context,
                              product: product,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // All Products Section
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'All Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Product>>(
                  future: ProductService.fetchProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No products found'));
                    } else {
                      final products = snapshot.data!;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: (products.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final firstIndex = index * 2;
                          final secondIndex = firstIndex + 1;

                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              0,
                              16,
                              0,
                            ),
                            child: Row(
                              children: [
                                if (firstIndex < products.length)
                                  Expanded(
                                    child: _buildSmallProductCard(
                                      context: context,
                                      product: products[firstIndex],
                                    ),
                                  ),
                                SizedBox(width: 8),
                                if (secondIndex < products.length)
                                  Expanded(
                                    child: _buildSmallProductCard(
                                      context: context,
                                      product: products[secondIndex],
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
                SizedBox(height: 80),
              ]),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => userHomePage(userId: widget.userId),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesPage(userId: widget.userId),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CartWidget(userId: widget.userId),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          Profile16SimpleProfileWidget(userId: widget.userId),
                ),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF6F61EF),
        unselectedItemColor: Colors.grey,
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
    );
  }
}
