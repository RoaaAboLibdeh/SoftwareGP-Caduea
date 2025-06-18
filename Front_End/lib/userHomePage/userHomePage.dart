import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/Categories/CategoryProductsPage.dart';
import 'package:cadeau_project/RandomBox/RandomBoxSelectionPage.dart';
import 'package:cadeau_project/User_Profile/user_profile.dart';
import 'package:cadeau_project/avatar_chat_page/avatar_chat_page.dart';
import 'package:cadeau_project/checkout_screen_map.dart/checkout_screen.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:cadeau_project/products_with_discount/products_with_discount.dart';
import 'package:cadeau_project/searchResults/searchResult.dart';
import 'package:cadeau_project/userCart/userCart.dart';
import 'package:cadeau_project/userHomePage/OccasionProductsPage.dart';
import 'package:cadeau_project/userHomePage/userHomePage_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  Map<String, String> categoryIdMap = {
    'Electronics':
        '680598ee06bcf640dab35547', // Replace with your actual category IDs
    'Handmade': '6812ac9393bb4108570ef160',
    'Toys': '6805993e06bcf640dab3554e',
    'Home Decor': '6805990806bcf640dab35549',
    'Books': '6805997006bcf640dab35554',
    'Personalized': '6805996006bcf640dab35552',
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

  Widget _buildImageFeatureButton({
    required String imageAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with cute bounce animation when pressed
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 100),
                tween: Tween<double>(begin: 1, end: 1),
                builder:
                    (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: Image.asset(
                        imageAsset,
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
              ),
            ),
            SizedBox(height: 8),
            // Cute text with shadow
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 8, 8, 8),
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this helper method to your widget class
  Widget _buildOccasionItem(String occasionName, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OccasionProductsPage(
                  occasion: occasionName,
                  userId: widget.userId, // Pass the userId from parent widget
                ),
          ),
        );
      },
      child: Container(
        width: 80, // Fixed width for each occasion item
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(255, 255, 254, 254),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              occasionName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
                          colors: [
                            Color.fromARGB(255, 124, 177, 255),
                            Color.fromARGB(255, 255, 180, 68),
                          ],
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
                                        color: Color.fromARGB(
                                          255,
                                          124,
                                          177,
                                          255,
                                        ),
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
                // Hero Banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Scrolling discount tags
                      Container(
                        height:
                            120, // Increased height to accommodate images and text
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                                _buildOccasionItem(
                                  'Birthday',
                                  'assets/images/ballons.png',
                                ),
                                _buildOccasionItem(
                                  'Graduation',
                                  'assets/images/Graduation.png',
                                ),
                                _buildOccasionItem(
                                  'Valentine',
                                  'assets/images/valentine.png',
                                ),
                                _buildOccasionItem(
                                  'Christmas',
                                  'assets/images/chris.png',
                                ),
                                _buildOccasionItem(
                                  'Anniversary',
                                  'assets/images/handmade.png',
                                ),
                              ]
                              .animate(interval: 100.ms)
                              .slideX(begin: 0.5, end: 0),
                        ),
                      ),

                      // Main banner
                      Container(
                        height: 220,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          // horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 4,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background Carousel - Now fully visible
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    height: double.infinity,
                                    viewportFraction: 1.0,
                                    autoPlay: true,
                                    autoPlayInterval: Duration(seconds: 3),
                                  ),
                                  items:
                                      [
                                        'assets/images/cute_gift_box.jpg',
                                        'assets/images/gift_box2.jpg',
                                        'assets/images/teddy_gift.jpg',
                                        'assets/images/gift3.jpg',
                                        'assets/images/gifts.jpg',
                                      ].map((path) {
                                        return Image.asset(
                                          path,
                                          fit: BoxFit.cover,
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),

                            // Semi-transparent overlay for better text visibility
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Cute floating elements
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Icon(
                                Icons.star,
                                size: 120,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Icon(
                                Icons.favorite,
                                size: 100,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🎀',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'CADEAU MAGIC',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 4,
                                                offset: Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Up to ',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '50% OFF ',
                                            style: GoogleFonts.poppins(
                                              color: Colors.yellowAccent,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'on gifts!',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton(
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color.fromARGB(
                                        255,
                                        113,
                                        182,
                                        255,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 6,
                                      shadowColor: Color.fromARGB(
                                        255,
                                        148,
                                        200,
                                        239,
                                      ).withOpacity(0.5),
                                      side: BorderSide(
                                        color: const Color.fromARGB(
                                          255,
                                          136,
                                          208,
                                          252,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'SHOP NOW!',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
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
                    ],
                  ),
                ),
                // Special Features Section (now comes after banner)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      _buildImageFeatureButton(
                        imageAsset: 'assets/images/gift1.png',
                        label: 'Choose a Surprise Box!',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RandomBoxSelectionPage(
                                      userId: widget.userId,
                                    ),
                              ),
                            ),
                      ),
                      _buildImageFeatureButton(
                        imageAsset: 'assets/images/3d_mug.png',
                        label: 'Customize Your Mug!',
                        onTap: () {
                          /* Mug navigation */
                        },
                      ),
                    ],
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
                        itemCount:
                            (products.length + 1) ~/ 2, // Handles odd counts
                        itemBuilder: (context, index) {
                          final firstIndex = index * 2;
                          final secondIndex = firstIndex + 1;

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // First product in row
                                if (firstIndex < products.length)
                                  Expanded(
                                    child: _buildSmallProductCard(
                                      context: context,
                                      product: products[firstIndex],
                                    ),
                                  ),
                                // Spacer (only if second product exists)
                                if (secondIndex < products.length)
                                  SizedBox(width: 8),
                                // Second product in row (if exists)
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
    );
  }
}
