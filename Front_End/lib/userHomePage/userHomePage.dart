import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/avatar_chat_page/avatar_chat_page.dart';
import 'package:cadeau_project/userCart/userCart.dart';
import 'package:cadeau_project/userHomePage/userHomePage_model.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import 'dart:ui';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
export 'userHomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/Categories/ListCategories.dart';
import '/custom/animations.dart';
import '/custom/widgets.dart';
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
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(
        Icons.category,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Categories',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      activeIcon: Icon(
        Icons.shopping_cart,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Cart',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outlined),
      activeIcon: Icon(
        Icons.person,
        color: Color(0xFF6F61EF),
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

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.14:5000/api/users/${widget.userId}'),
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

  Widget _buildSmallProductCard({
    required String imageUrl,
    required String title,
    required String price,
    String? oldPrice,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                if (oldPrice != null)
                  Text(
                    oldPrice,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 6, 16, 6),
                        child: Container(
                          width: 53,
                          height: 53,
                          decoration: BoxDecoration(
                            color: Color(0x4D9489F5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF6F61EF),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  isLoading
                                      ? CircularProgressIndicator(
                                        strokeWidth: 2,
                                      )
                                      : (userData?['avatar'] != null &&
                                          userData!['avatar'].isNotEmpty)
                                      ? Container(
                                        width: 300,
                                        height: 200,
                                        child: AvatarPlus(
                                          userData?['avatar'] ?? 'ak',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Image.network(
                                        'https://picsum.photos/seed/626/600',
                                        width: 300,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToAvatarChat(),
                          child: Text(
                            'Hey ${userData != null ? userData!['name'] ?? 'User' : 'User'}, Let\'s talk!',
                            style: FlutterFlowTheme.of(
                              context,
                            ).headlineMedium.override(
                              fontFamily: 'Outfit',
                              color: Color(0xFF15161E),
                              fontSize: 17,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 40,
                          buttonSize: 40,
                          icon: Icon(
                            Icons.notifications_none,
                            color: Color(0xFF15161E),
                            size: 24,
                          ),
                          onPressed: () {
                            print('IconButton pressed ...');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                StickyHeader(
                  overlapHeaders: false,
                  header: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF6F61EF),
                                  size: 24,
                                ),
                                hintText: 'Search for products...',
                                hintStyle: FlutterFlowTheme.of(
                                  context,
                                ).labelMedium.override(
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              style: TextStyle(
                                color: Color(0xFF223263),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              cursorColor: Color(0xFF6F61EF),
                            ),
                          ),
                        ),

                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                        child: Container(
                          width: double.infinity,
                          height: 230,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/discount2.jpg'),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x250F1113),
                                offset: Offset(0.0, 1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(0x430F1113),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                12,
                                12,
                                12,
                                0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      0,
                                      70,
                                      0,
                                    ),
                                    child: Text(
                                      'Gifting just got sweeter — special deals waiting for you!',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).headlineMedium.override(
                                        fontFamily: 'Outfit',
                                        color: Colors.white,
                                        fontSize: 24,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      16,
                                      0,
                                      0,
                                    ),
                                    child: Text(
                                      'Give More, Spend Less',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).titleSmall.override(
                                        fontFamily: 'Outfit',
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      8,
                                      0,
                                      0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        // ... (keep all the existing user avatar images code) ...
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      12,
                                      0,
                                      0,
                                    ),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      text: 'Shop Now!',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 44,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0,
                                          0,
                                          0,
                                          0,
                                        ),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0,
                                              0,
                                              0,
                                              0,
                                            ),
                                        color: Color.fromARGB(
                                          255,
                                          171,
                                          158,
                                          226,
                                        ), // Changed to your desired color
                                        textStyle: FlutterFlowTheme.of(
                                          context,
                                        ).titleSmall.override(
                                          fontFamily: 'Outfit',
                                          color:
                                              Colors
                                                  .white, // White text for contrast
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        elevation: 2,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                        child: Text(
                          'Top Beaches',
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
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                        child: Container(
                          width: double.infinity,
                          height: 270,
                          decoration: BoxDecoration(),
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Container(
                                  width: 140, // Sleek smaller width
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      6,
                                    ), // Smaller border radius
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image with padding and badges
                                      Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(
                                              4,
                                            ), // Padding between image and border
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    8,
                                                  ), // Smooth corners
                                              child: Image.network(
                                                'https://images.unsplash.com/photo-1519046904884-53103b34b206?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8YmVhY2h8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=80',
                                                width: double.infinity,
                                                height: 160, // Taller image
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    height: 140,
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // Discount Badge (red)
                                          Positioned(
                                            top: 16,
                                            left: 16,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                  255,
                                                  239,
                                                  66,
                                                  54,
                                                ), // Red color
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '40% OFF',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Favorite Button
                                          Positioned(
                                            top: 16,
                                            right: 16,
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.favorite_border,
                                                size: 18,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          // Quick Add Button
                                          Positioned(
                                            bottom: 16,
                                            right: 16,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF6F61EF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Product Details
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product Name
                                            Text(
                                              'Summer Beach',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 6),

                                            // Price Row
                                            Row(
                                              children: [
                                                Text(
                                                  '\$25.99',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6F61EF),
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  '\$42.99',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 16)),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Color(0xFFF1F4F8)),
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
                                                    imageUrl:
                                                        products[firstIndex]
                                                                .imageUrls
                                                                .isNotEmpty
                                                            ? products[firstIndex]
                                                                .imageUrls[0]
                                                            : 'https://via.placeholder.com/150',
                                                    title:
                                                        products[firstIndex]
                                                            .name,
                                                    price:
                                                        '\$${products[firstIndex].price.toStringAsFixed(2)}',
                                                    oldPrice:
                                                        products[firstIndex]
                                                                    .discountAmount !=
                                                                null
                                                            ? '\$${(products[firstIndex].price + products[firstIndex].discountAmount!).toStringAsFixed(2)}'
                                                            : null,
                                                  ),
                                                ),
                                              SizedBox(width: 8),
                                              if (secondIndex < products.length)
                                                Expanded(
                                                  child: _buildSmallProductCard(
                                                    imageUrl:
                                                        products[secondIndex]
                                                                .imageUrls
                                                                .isNotEmpty
                                                            ? products[secondIndex]
                                                                .imageUrls[0]
                                                            : 'https://via.placeholder.com/150',
                                                    title:
                                                        products[secondIndex]
                                                            .name,
                                                    price:
                                                        '\$${products[secondIndex].price.toStringAsFixed(2)}',
                                                    oldPrice:
                                                        products[secondIndex]
                                                                    .discountAmount !=
                                                                null
                                                            ? '\$${(products[secondIndex].price + products[secondIndex].discountAmount!).toStringAsFixed(2)}'
                                                            : null,
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
              selectedItemColor: Color(0xFF6F61EF),
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: FlutterFlowTheme.of(
                context,
              ).titleSmall.override(
                fontFamily: 'Outfit',
                color: Color(
                  0xFF6F61EF,
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
