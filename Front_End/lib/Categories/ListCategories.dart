import 'package:cadeau_project/custom/theme.dart';
import 'package:cadeau_project/userCart/userCart.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class CategoriesPage extends StatefulWidget {
  final String userId; // Add userId parameter

  const CategoriesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';
  int _currentIndex = 1;

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
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.88.100:5000/api/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['categories'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load categories. Please try again.';
      });
      debugPrint('Error fetching categories: $e');
    }
  }

  IconData _getIconFromString(String iconName) {
    // Maps icon string names to actual Material icons
    switch (iconName.toLowerCase()) {
      case 'electrical_services':
        return Icons.electrical_services;
      case 'diamond':
        return Icons.diamond;
      case 'home':
        return Icons.home;
      case 'checkroom':
        return Icons.checkroom;
      case 'toys':
        return Icons.toys;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'edit':
        return Icons.edit;
      case 'menu_book':
        return Icons.menu_book;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }

  String _getFallbackImageUrl(String categoryName) {
    // Default images when none is provided in the database
    return 'https://via.placeholder.com/300?text=${Uri.encodeComponent(categoryName)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCategories,
        child: _buildContent(),
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
                    builder: (context) => CategoriesPage(userId: widget.userId),
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
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Categories'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter category name',
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Implement search
                  Navigator.pop(context);
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F61EF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return const Center(
        child: Text('No categories available', style: TextStyle(fontSize: 16)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final name = category['name'] ?? 'Unnamed Category';
        final icon = category['icon'] ?? 'category';
        final imageUrl = category['image'] ?? _getFallbackImageUrl(name);

        return _buildCategoryCard(name, icon, imageUrl);
      },
    );
  }

  Widget _buildCategoryCard(String name, String icon, String imageUrl) {
    return GestureDetector(
      onTap: () => _navigateToCategoryProducts(context, name),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            _getIconFromString(icon),
                            color: const Color.fromARGB(255, 164, 145, 240),
                            size: 40,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _getIconFromString(icon),
                    color: const Color.fromARGB(255, 164, 145, 240),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategoryProducts(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(category: categoryName),
      ),
    );
  }
}

class CategoryProductsPage extends StatelessWidget {
  final String category;

  const CategoryProductsPage({Key? key, required this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Products in $category category',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
