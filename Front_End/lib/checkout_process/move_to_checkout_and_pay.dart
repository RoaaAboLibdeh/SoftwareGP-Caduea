import 'package:cadeau_project/checkout_screen_map.dart/checkout_screen.dart';
import 'package:cadeau_project/home_page_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MoveToCheckoutAndPay extends StatefulWidget {
  final String userId;
  final double totalAmount;

  const MoveToCheckoutAndPay({
    super.key,
    required this.userId,
    required this.totalAmount,
  });

  @override
  State<MoveToCheckoutAndPay> createState() => _MoveToCheckoutAndPayState();
}

class _MoveToCheckoutAndPayState extends State<MoveToCheckoutAndPay>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _selectedOption;
  bool _isProcessing = false;

  // Payment options data
  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'title': 'Pay in Store',
      'subtitle': 'Visit our store to complete payment',
      'icon': Icons.store,
      'color': const Color(0xFF0984E3),
      'gradient': const LinearGradient(
        colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    // {
    //   'title': 'Pay with Cash',
    //   'subtitle': 'Pay when you receive your order',
    //   'icon': Icons.wallet,
    //   'color': const Color(0xFF00B894),
    //   'gradient': const LinearGradient(
    //     colors: [Color(0xFF00B894), Color(0xFF74B9FF)],
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //   ),
    // },
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
    });
    // Haptic feedback for selection
    Feedback.forTap(context);
    if (index == 2) {
      _navigateToCardPayment();
    }
  }

  Future<void> _processPayment() async {
    if (_selectedOption == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isProcessing = false;
    });

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Payment Scheduled'),
            content: Text(
              _selectedOption == 0
                  ? 'Your cash payment of \$${widget.totalAmount.toStringAsFixed(2)} will be collected upon delivery'
                  : 'Please visit our store to complete your payment of \$${widget.totalAmount.toStringAsFixed(2)}',
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

  void _navigateToCardPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomePagePayment()),
    );
    // Navigator.push(context, MaterialPageRoute(builder: (_) => CardPaymentScreen()));
  }

  void _navigateToMapPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen()), //move to map
    );
    // Navigator.push(context, MaterialPageRoute(builder: (_) => CardPaymentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(opacity: _fadeAnimation.value, child: child),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const Spacer(),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _entryController,
                          curve: const Interval(0.4, 0.8),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.payment_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Select Payment Method',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to pay for your order.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: screenHeight * 0.035),

                // Total amount display - redesigned
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total to Pay',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${widget.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment options
                Column(
                  children: List.generate(_paymentOptions.length, (index) {
                    final option = _paymentOptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PaymentOptionCard(
                        index: index,
                        isSelected: _selectedOption == index,
                        onSelect: _selectOption,
                        icon: option['icon'] as IconData,
                        title: option['title'] as String,
                        subtitle: option['subtitle'] as String,
                        gradient: option['gradient'] as Gradient,
                        color: option['color'] as Color,
                      ),
                    );
                  }),
                ),
                //pay when u recive your order
                GestureDetector(
                  onTap: _navigateToMapPage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B894).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.payment_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Pay with Cash',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Card Payment button
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _navigateToCardPayment,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF39C12), Color(0xFFFDCB6E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF39C12).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.payment_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Pay with Card',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Confirm button or loader
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _isProcessing
                            ? _LoadingAnimation(color: colorScheme.primary)
                            : ElevatedButton(
                              onPressed:
                                  _selectedOption != null
                                      ? _processPayment
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Confirm Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Function(int) onSelect;
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color color;

  const _PaymentOptionCard({
    required this.index,
    required this.isSelected,
    required this.onSelect,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border:
              isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingAnimation extends StatelessWidget {
  final Color color;

  const _LoadingAnimation({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
