import 'package:cadeau_project/models/product_model.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersFavorite extends StatefulWidget {
  final String userId;

  const UsersFavorite({Key? key, required this.userId}) : super(key: key);

  @override
  _UsersFavoriteState createState() => _UsersFavoriteState();
}

class _UsersFavoriteState extends State<UsersFavorite> {
  List<dynamic> favoriteProducts = [];
  bool isLoading = true;
  Set<String> removingItems = Set(); // Track items being removed

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final response = await http.get(
      Uri.parse('http://192.168.88.100:5000/api/favorites/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        favoriteProducts =
            data['items']
                .map(
                  (item) => {...item['product'], '_id': item['product']['_id']},
                )
                .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Failed to load favorites: ${response.body}');
    }
  }

  Future<void> removeFavorite(String productId) async {
    setState(() => removingItems.add(productId));

    try {
      final response = await http.delete(
        Uri.parse(
          'http://192.168.88.100:5000/api/favorites/${widget.userId}/items/$productId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteProducts.removeWhere((p) => p['_id'] == productId);
          removingItems.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from favorites'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      setState(() => removingItems.remove(productId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        elevation: 2,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteProducts.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  final imageUrl =
                      (product['imageUrls'] != null &&
                              product['imageUrls'].isNotEmpty)
                          ? product['imageUrls'][0]
                          : null;
                  final isRemoving = removingItems.contains(product['_id']);

                  return AnimatedOpacity(
                    opacity: isRemoving ? 0.5 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Dismissible(
                      key: Key(product['_id']),
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red[100],
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed:
                          (direction) => removeFavorite(product['_id']),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Remove from favorites?'),
                                content: Text(
                                  'Are you sure you want to remove this item from your favorites?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: GestureDetector(
                        onTap:
                            isRemoving
                                ? null
                                : () {
                                  // Convert the product map to a strongly typed Map<String, dynamic>
                                  final productData = Map<String, dynamic>.from(
                                    product,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProductDetailsWidget(
                                            product: Product.fromJson(
                                              productData,
                                            ),
                                            userId: widget.userId,
                                          ),
                                    ),
                                  );
                                },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child:
                                        imageUrl != null
                                            ? Image.network(
                                              imageUrl,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                            )
                                            : Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image),
                                            ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'] ?? 'Unnamed',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            product['description'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '\$${product['price'].toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => removeFavorite(product['_id']),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.redAccent.withOpacity(
                                        isRemoving ? 0.3 : 0.1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child:
                                        isRemoving
                                            ? CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.redAccent,
                                                  ),
                                            )
                                            : const Icon(
                                              Icons.favorite,
                                              color: Colors.redAccent,
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
