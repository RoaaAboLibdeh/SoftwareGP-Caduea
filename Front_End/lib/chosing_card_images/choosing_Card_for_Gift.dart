import 'package:cadeau_project/checkout_process/move_to_checkout_and_pay.dart';
import 'package:cadeau_project/checkout_screen_map.dart/checkout_screen.dart';
import 'package:cadeau_project/models/userCart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChoosingCardForGift extends StatefulWidget {
  final String userId;
  final List<CartItem> cartItems;
  final double subtotal;
  final double shipping;
  final double total;
  final Map<String, dynamic> giftBoxData;
  const ChoosingCardForGift({
    super.key,
    required this.userId,
    required this.cartItems,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.giftBoxData,
  });

  @override
  State<ChoosingCardForGift> createState() => _ChoosingCardForGiftState();
}

class _ChoosingCardForGiftState extends State<ChoosingCardForGift> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int _selectedCardIndex = 0;
  final List<String> _cardImages = [
    'assets/images/card1.jpg',
    'assets/images/card2.jpg',
    'assets/images/card3.jpg',
    'assets/images/card4.jpg',
    'assets/images/card5.jpg',
  ];
  final Color blueColor = const Color.fromARGB(255, 124, 177, 255);
  final Color orangeColor = const Color.fromARGB(255, 255, 180, 68);
  @override
  void dispose() {
    _nameController.dispose();
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Your Gift Card',
          style: TextStyle(color: Colors.black), // explicitly set to black
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // changed from white to black
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personalize Your Gift',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(221, 43, 71, 198),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make your gift extra special with a custom card.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              _buildInputField(
                label: 'Your Name',
                controller: _nameController,
                icon: Icons.person_outline,
                iconColor: blueColor,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: "Recipient's Name",
                controller: _recipientController,
                icon: Icons.card_giftcard,
                iconColor: blueColor,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Your Message',
                controller: _messageController,
                icon: Icons.message_outlined,
                maxLines: 4,
                iconColor: blueColor,
              ),
              const SizedBox(height: 30),

              Text(
                'Choose a Card Design',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: orangeColor,
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cardImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 15),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCardIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCardIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected
                                    ? blueColor
                                    : const Color.fromARGB(255, 255, 255, 255)!,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _cardImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  _showPreviewDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 190, 216, 255),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text(
                  'Preview Card',
                  style: TextStyle(color: Color.fromARGB(255, 34, 81, 190)),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MoveToCheckoutAndPay(
                              userId: widget.userId,
                              cartItems: widget.cartItems,
                              subtotal: widget.subtotal,
                              shipping: widget.shipping,
                              total: widget.total,
                              giftBoxData: widget.giftBoxData,
                              giftCardData: {
                                'cardImage': _cardImages[_selectedCardIndex],
                                'senderName': _nameController.text,
                                'recipientName': _recipientController.text,
                                'message': _messageController.text,
                              },
                            ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 124, 177, 255),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                label: Text(
                  'Create Gift Card',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    required Color iconColor,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black), // <-- Add this line
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: blueColor), // Blue label text
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: blueColor), // Blue border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: blueColor), // Blue border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: blueColor,
            width: 2,
          ), // Thicker blue border when focused
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Card Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.asset(_cardImages[_selectedCardIndex]),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To: ${_recipientController.text}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_messageController.text),
                                  const SizedBox(height: 8),
                                  Text(
                                    'From: ${_nameController.text}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Looks Good!'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _submitCard() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Success!'),
            content: const Text(
              'Your gift card has been created successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
