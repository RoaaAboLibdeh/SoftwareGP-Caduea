import 'package:cadeau_project/RandomBox/RandomBoxSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:lottie/lottie.dart';
import 'package:cadeau_project/models/product_model.dart';

class RandomBoxPage extends StatefulWidget {
  final String userId;
  final PriceTier priceTier;

  const RandomBoxPage({Key? key, required this.userId, required this.priceTier})
    : super(key: key);

  @override
  _RandomBoxPageState createState() => _RandomBoxPageState();
}

class _RandomBoxPageState extends State<RandomBoxPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  List<Product> _randomProducts = [];
  bool _isLoading = true;
  bool _showAllItems = false;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _fetchRandomProducts();
  }

  Future<void> _fetchRandomProducts() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    // Mock data - in a real app, you'd fetch from your API
    setState(() {
      _randomProducts = List.generate(
        widget.priceTier.price ~/ 10 + 1,
        (index) => Product(
          id: 'prod${index + 100}',
          name: 'Premium Item ${index + 1}',
          description: 'Amazing product you\'ll love!',
          price:
              (widget.priceTier.price * 1.5) /
              (widget.priceTier.price ~/ 10 + 1),
          discountAmount: 0,
          imageUrls: ['https://picsum.photos/200/300?random=$index'],
          recipientType: ['Everyone'],
          occasion: ['Any'],
          stock: 10,
          isOnSale: false,
          category: 'Random Box',
        ),
      );

      _totalValue = _randomProducts.fold(
        0,
        (sum, product) => sum + product.price,
      );
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _revealAllItems() {
    setState(() {
      _showAllItems = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.9,
                child: Lottie.asset(
                  'assets/confetti.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Your ${widget.priceTier.title}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  if (_isLoading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/loading.json',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Preparing your surprise...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          // Unboxing animation
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _opacityAnimation.value,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Lottie.asset(
                              'assets/unboxing.json',
                              width: 200,
                              height: 200,
                              repeat: true,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Value information
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You paid:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '\$${widget.priceTier.price}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total value:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '\$${_totalValue.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Items header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Items (${_randomProducts.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_showAllItems)
                                TextButton(
                                  onPressed: _revealAllItems,
                                  child: Text('Reveal All'),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Items list
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  _showAllItems ? _randomProducts.length : 1,
                              itemBuilder: (context, index) {
                                final product = _randomProducts[index];
                                return AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return SlideTransition(
                                      position: _slideAnimation,
                                      child: FadeTransition(
                                        opacity: _opacityAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildProductItem(product),
                                );
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
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrls.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Color(0xFF6F61EF)),
                  ),
                ],
              ),
            ),

            // Add to cart button
            IconButton(
              icon: Icon(Icons.add_shopping_cart),
              color: Color(0xFF6F61EF),
              onPressed: () {
                // Add to cart functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to cart')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
