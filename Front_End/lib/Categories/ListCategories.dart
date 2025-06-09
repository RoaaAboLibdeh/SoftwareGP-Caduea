import 'package:cadeau_project/Categories/CategoryProductsPage.dart';
import 'package:cadeau_project/User_Profile/user_profile.dart';
import 'package:cadeau_project/custom/theme.dart';
import 'package:cadeau_project/userCart/userCart.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class CategoriesPage extends StatefulWidget {
  final String userId;

  const CategoriesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> categories = [];
  bool isLoading = true;
  String errorMessage = '';
  int _currentIndex = 1;

  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.home_outlined, size: 24),
      ),
      activeIcon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 180, 68).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.home,
          color: Color.fromARGB(255, 124, 177, 255),
          size: 24,
        ),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.category_outlined, size: 24),
      ),
      activeIcon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 180, 68).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.category,
          color: Color.fromARGB(255, 124, 177, 255),
          size: 24,
        ),
      ),
      label: 'Categories',
    ),
    BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.shopping_cart_outlined, size: 24),
      ),
      activeIcon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 180, 68).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.shopping_cart,
          color: Color.fromARGB(255, 124, 177, 255),
          size: 24,
        ),
      ),
      label: 'Cart',
    ),
    BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.person_outlined, size: 24),
      ),
      activeIcon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 180, 68).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person,
          color: Color.fromARGB(255, 124, 177, 255),
          size: 24,
        ),
      ),
      label: 'Profile',
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
    return 'https://placehold.co/300x300/EEE/6F61EF?text=${Uri.encodeComponent(categoryName)}';
  }

  String _getCategoryImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _getFallbackImageUrl('Category');
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    // Handle cases where imagePath might already contain part of the URL
    if (imagePath.startsWith('/uploads/')) {
      return 'http://192.168.88.100:5000$imagePath';
    }

    // Default case - construct the URL properly
    return 'http://192.168.88.100:5000/uploads/${imagePath.replaceFirst('/uploads/', '')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        userHomePage(userId: widget.userId), // Pass the userId
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCategories,
        color: Color.fromARGB(255, 124, 177, 255),
        child: _buildContent(),
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

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color.fromARGB(255, 124, 177, 255),
            ),
            SizedBox(height: 16),
            Text(
              'Loading categories...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red[400],
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchCategories,
                child: Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 124, 177, 255),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, color: Colors.grey[400], size: 64),
            SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final name = category['name'] ?? 'Unnamed Category';
        final icon = category['icon'] ?? 'category';
        final imagePath = category['image'];
        final imageUrl = _getCategoryImageUrl(imagePath);
        final categoryId = category['_id'] ?? ''; // Add this line

        return _buildCategoryCard(name, icon, imageUrl, categoryId);
      },
    );
  }

  Widget _buildCategoryCard(
    String name,
    String icon,
    String imageUrl,
    String categoryId,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCategoryProducts(context, name, categoryId),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 124, 177, 255),
                              ),
                            ),
                        errorWidget: (context, url, error) {
                          debugPrint('Image load error: $error for URL: $url');
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey[400],
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconFromString(icon),
                            color: Color.fromARGB(255, 124, 177, 255),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategoryProducts(
    BuildContext context,
    String categoryName,
    String categoryId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryProductsPage(
              category: categoryName,
              categoryId: categoryId,
              userId: widget.userId,
            ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Search Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter category name...',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Implement search
                          Navigator.pop(context);
                        },
                        child: Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 124, 177, 255),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// class CategoryProductsPage extends StatelessWidget {
//   final String category;

//   const CategoryProductsPage({
//     Key? key,
//     required this.category,
//     required String categoryId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           category,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.category_rounded,
//               size: 64,
//               color: Color.fromARGB(255, 255, 180, 68).withOpacity(0.2),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Products in $category category',
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
