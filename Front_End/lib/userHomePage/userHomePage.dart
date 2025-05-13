import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/avatar_chat_page/avatar_chat_page.dart';
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

  static String routeName = 'basepageanotherchoice';
  static String routePath = '/basepageanotherchoice';

  @override
  State<userHomePage> createState() => _userHomePageState();
}

class _userHomePageState extends State<userHomePage> {
  int _currentIndex = 0; // Tracks the selected tab
  late BasepageanotherchoiceModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

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

  // Bottom Navigation Items (like SHEIN)
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(
        Icons.home,
        color: Color.fromARGB(255, 164, 145, 240),
      ), // Active icon color
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(
        Icons.category,
        color: Color.fromARGB(255, 164, 145, 240),
      ), // Active icon color
      label: 'Categories',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      activeIcon: Icon(
        Icons.shopping_cart,
        color: Color.fromARGB(255, 164, 145, 240),
      ), // Active icon color
      label: 'Cart',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outlined),
      activeIcon: Icon(
        Icons.person,
        color: Color.fromARGB(255, 164, 145, 240),
      ), // Active icon color
      label: 'Me',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => BasepageanotherchoiceModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // Fetch user data when the page loads
    _fetchUserData();
  }

  Future<List<Product>> fetchDiscountedProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.88.100:5000/products/discounted'),
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load discounted products');
    }
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

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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

  // Add this above your build method or inside your State class
  void _performSearch(BuildContext context) async {
    final query = _model.textController.text.trim();
    if (query.isNotEmpty) {
      final response = await http.get(
        Uri.parse(
          'http://192.168.88.100:5000/api/products/search?q=$query',
        ), // Replace with real URL
        // headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final results = jsonData.map((e) => Product.fromJson(e)).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    SearchResultPage(products: results, userId: widget.userId),
          ),
        );
      } else {
        print("Search failed with status: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  // Top Profile Row (Avatar + Name + Notification)
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF6F61EF), Color(0x4D9489F5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x806F61EF),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Color(0xFF6F61EF),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  isLoading
                                      ? Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                      : (userData?['avatar'] != null &&
                                          userData!['avatar'].isNotEmpty)
                                      ? AvatarPlus(
                                        userData?['avatar'] ?? 'ak',
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToAvatarChat(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Hey ${userData != null ? userData!['name'] ?? 'User' : 'User'}, Let\'s talk!',
                              style: FlutterFlowTheme.of(
                                context,
                              ).headlineMedium.override(
                                fontFamily: 'Outfit',
                                color: Color(0xFF15161E),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F4F8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1A6F61EF),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 40,
                            buttonSize: 44,
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF15161E),
                              size: 26,
                            ),
                            onPressed: () {
                              print('Notification pressed...');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                StickyHeader(
                  overlapHeaders: false,
                  // Inside your widget
                  header: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x116F61EF),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFF8F8F8), Color(0xFFF1F4F8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x206F61EF),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              // onSubmitted: (_) => _performSearch(context),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Color.fromARGB(255, 164, 145, 240),
                                  size: 22,
                                ),
                                hintText: 'Search for products...',
                                hintStyle: FlutterFlowTheme.of(
                                  context,
                                ).labelMedium.override(
                                  fontFamily: 'Outfit',
                                  color: Color(0xFF9E9E9E),
                                  letterSpacing: 0.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                              ),
                              style: TextStyle(
                                color: Color(0xFF15161E),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: Color.fromARGB(255, 160, 140, 240),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Search Button
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 164, 145, 240),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x306F61EF),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            onPressed: () => _performSearch(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Container(
                          width: double.infinity,
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage('assets/images/disc3.jpg'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Special Sales Just for You!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Up to 50% off selected items.\nLimited time only!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  ProductsWithDiscountPage(
                                                    userId: widget.userId,
                                                  ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.shopping_bag_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        164,
                                        145,
                                        240,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recommended',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            // TextButton(
                            //   onPressed: () {},
                            //   child: Text(
                            //     'See all',
                            //     style: TextStyle(
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.w500,
                            //       color: Color(0xFF6F61EF),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      FutureBuilder<List<Product>>(
                        future: fetchTopPopularProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                16,
                                16,
                                0,
                                12,
                              ),
                              child: Text(
                                'Recent Properties',
                                style: FlutterFlowTheme.of(
                                  context,
                                ).labelMedium.override(
                                  fontFamily: 'Outfit',
                                  color: Color(0xFF606A85),
                                  fontSize: 14,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                44,
                              ),
                              child: FutureBuilder<List<Product>>(
                                future: ProductService.fetchProducts(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text('No products found'),
                                    );
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
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                    product:
                                                        products[firstIndex],
                                                  ),
                                                ),
                                              SizedBox(width: 8),
                                              if (secondIndex < products.length)
                                                Expanded(
                                                  child: _buildSmallProductCard(
                                                    context: context,
                                                    product:
                                                        products[secondIndex],
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 👇 SHEIN-like Bottom Navigation Bar
        // Bottom Navigation Bar implementation
        bottomNavigationBar: Container(
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
                if (index == _currentIndex)
                  return; // 👈 Prevents duplicate pushes

                setState(() => _currentIndex = index);

                if (index == 0) {
                  Navigator.pushReplacement(
                    // 👈 Use pushReplacement to avoid stack buildup
                    context,
                    MaterialPageRoute(
                      builder: (context) => userHomePage(userId: widget.userId),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CategoriesPage(userId: widget.userId),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartWidget(userId: widget.userId),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartWidget(userId: widget.userId),
                    ), // 👈 Changed to ProfilePage (assuming "Me" is a profile)
                  );
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color.fromARGB(255, 164, 145, 240),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: FlutterFlowTheme.of(
                context,
              ).titleSmall.override(
                fontFamily: 'Outfit',
                color: Color.fromARGB(
                  255,
                  164,
                  145,
                  240,
                ), // Using your purple color for selected text
                fontSize: 12, // Adjusted to match typical bottom nav text size
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600, // Slightly bolder for selected
              ),
              unselectedLabelStyle: FlutterFlowTheme.of(
                context,
              ).titleSmall.override(
                fontFamily: 'Outfit',
                color: Colors.grey[600],
                fontSize: 12,
                letterSpacing: 0.0,
                fontWeight: FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: _bottomNavItems,
            ),
          ),
        ),
      ),
    );
  }
}
