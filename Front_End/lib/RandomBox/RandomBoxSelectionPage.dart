import 'package:cadeau_project/RandomBox/RandomBoxPage.dart';
import 'package:cadeau_project/home_page_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:cadeau_project/models/product_model.dart';

class RandomBoxSelectionPage extends StatefulWidget {
  final String userId;

  const RandomBoxSelectionPage({Key? key, required this.userId})
    : super(key: key);

  @override
  _RandomBoxSelectionPageState createState() => _RandomBoxSelectionPageState();
}

class _RandomBoxSelectionPageState extends State<RandomBoxSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  int? _selectedTier;

  final List<PriceTier> _priceTiers = [
    PriceTier(
      price: 10,
      title: "Mini Surprise",
      description: "1-2 quality items (value \$15+)",
      icon: Icons.card_giftcard,
      color: Colors.purple,
    ),
    PriceTier(
      price: 20,
      title: "Standard Box",
      description: "2-3 premium items (value \$30+)",
      icon: Icons.star,
      color: Colors.blue,
    ),
    PriceTier(
      price: 50,
      title: "Deluxe Package",
      description: "4-5 luxury items (value \$75+)",
      icon: Icons.diamond,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _navigateToPayment(BuildContext context, PriceTier tier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20), // ✅ This is a parameter of Container
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              // padding: EdgeInsets.all(20),
            ),
            child: Column(
              // ✅ This is a parameter of Container
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.credit_card, color: Colors.blue),
                  title: Text('Pay with Card'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePagePayment(),
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.money, color: Colors.green),
                  title: Text('Pay with Cash'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RandomBoxPage(
                              userId: widget.userId,
                              priceTier: tier,
                            ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F8),
      appBar: AppBar(
        title: Text('Random Box'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned(top: -50, right: -50, child: Opacity(opacity: 0.1)),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/gift.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose Your Surprise Box',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Get amazing products at incredible value!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Price tiers
                Text(
                  'Select a box tier:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: _priceTiers.length,
                    itemBuilder: (context, index) {
                      final tier = _priceTiers[index];
                      return AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                _selectedTier == index
                                    ? _scaleAnimation.value
                                    : 1.0,
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTier = index;
                            });
                            _confettiController.play();
                          },
                          child: Container(
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
                              border: Border.all(
                                color:
                                    _selectedTier == index
                                        ? tier.color
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: tier.color.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      tier.icon,
                                      color: tier.color,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tier.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          tier.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tier.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '\$${tier.price}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: tier.color,
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
                ),

                // Continue button
                if (_selectedTier != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToPayment(
                          context,
                          _priceTiers[_selectedTier!],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 124, 177, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Text(
                        'Continue to Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Confetti effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PriceTier {
  final int price;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  PriceTier({
    required this.price,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
