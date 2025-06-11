import 'package:cadeau_project/models/product_model.dart';
import 'package:cadeau_project/product/ProductDetailsForUser/ProductDetailsForUser.dart';
import 'package:flutter/material.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:cadeau_project/custom/theme.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'chat_message.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AvatarChatPage extends StatefulWidget {
  final String avatarCode;
  final String avatarName;
  final String userId;
  final String userName;

  const AvatarChatPage({
    super.key,
    required this.avatarCode,
    required this.avatarName,
    required this.userId,
    required this.userName,
  });

  @override
  State<AvatarChatPage> createState() => _AvatarChatPageState();
}

class _AvatarChatPageState extends State<AvatarChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isAvatarTyping = false;
  late ApiService _apiService;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
      userId: widget.userId,
      avatarId: widget.avatarCode,
    );
    _loadChatHistory();
    _addWelcomeMessage();
  }

  Future<void> _loadChatHistory() async {
    final history = await _apiService.getChatHistory();
    setState(() => _messages.addAll(history));
  }

  void _addWelcomeMessage() {
    _addAvatarMessage(
      "Hello ${widget.userName}! I'm ${widget.avatarName}, your personal gift assistant. 🎁\n\nI can help you find the perfect gift for any occasion. Tell me who you're shopping for and I'll suggest wonderful options!",
    );
  }

  void _addAvatarMessage(String text, {bool isProductRecommendation = false}) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isAvatar: true,
          timestamp: DateTime.now(),
          isProductRecommendation: isProductRecommendation,
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    // Add user message
    setState(
      () => _messages.add(
        ChatMessage(
          text: userMessage,
          isAvatar: false,
          timestamp: DateTime.now(),
        ),
      ),
    );
    _scrollToBottom();

    // Show typing indicator
    setState(() => _isAvatarTyping = true);

    try {
      // Get API response
      final response = await _apiService.getAvatarResponse(
        userMessage,
        _messages,
      );
      _addAvatarMessage(response);
    } catch (e) {
      _addAvatarMessage("Oops! Something went wrong. Please try again later.");
    }
  }

  Future<void> sendMessageToBot(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isAvatar: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    try {
      setState(() => _isAvatarTyping = true);

      final response = await http.post(
        Uri.parse('http://192.168.88.100:5000/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addAvatarMessage(
          data['message'],
          isProductRecommendation: data['isProductRecommendation'] ?? false,
        );
      } else {
        throw Exception('Failed to get response from server');
      }
    } catch (e) {
      _addAvatarMessage("Oops! I couldn't connect to the gift assistant.");
    } finally {
      setState(() => _isAvatarTyping = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              child: AvatarPlus(widget.avatarCode, width: 32, height: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.avatarName,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
                ),
                if (_isAvatarTyping)
                  Text(
                    'typing...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 124, 177, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 124, 177, 255),
                    Colors.white,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isAvatarTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    final message = _messages[index];
                    return message.isProductRecommendation
                        ? ProductRecommendationBubble(
                          message: message.text,
                          avatarCode: widget.avatarCode,
                          avatarName: widget.avatarName,
                          onProductTap: _launchURL,
                          userId: widget.userId,
                        )
                        : ChatBubble(
                          message: message.text,
                          isAvatar: message.isAvatar,
                          avatarCode: widget.avatarCode,
                          avatarName: widget.avatarName,
                        );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                      // child: TypingIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask for a gift idea...',
                        // border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // Optionally open emoji picker
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.send, color: Colors.blueAccent),
                  //   onPressed: () {
                  //     final text = _controller.text.trim();
                  //     if (text.isNotEmpty) {
                  //       sendMessageToBot(text);
                  //       _controller.clear();
                  //     }
                  //   },
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Color.fromARGB(255, 124, 177, 255),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  sendMessageToBot(text);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isAvatar;
  final String avatarName;
  final String avatarCode;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isAvatar,
    required this.avatarName,
    required this.avatarCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAvatar) ...[
            Container(
              width: 36,
              height: 36,
              child: AvatarPlus(avatarCode, width: 36, height: 36),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isAvatar ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isAvatar
                            ? Colors.grey[100]
                            : Color.fromARGB(255, 124, 177, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isAvatar ? 0 : 16),
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: Radius.circular(isAvatar ? 16 : 0),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isAvatar ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvatar ? avatarName : "You",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isAvatar) const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class ProductRecommendationBubble extends StatelessWidget {
  final String message;
  final String avatarName;
  final String avatarCode;
  final String userId;
  final Function(String) onProductTap;

  const ProductRecommendationBubble({
    super.key,
    required this.message,
    required this.avatarName,
    required this.avatarCode,
    required this.onProductTap,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the message to extract product information
    final products = _parseProductRecommendations(message);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            child: AvatarPlus(avatarCode, width: 36, height: 36),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The introductory message
                      if (message.contains('\n'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            message.substring(0, message.indexOf('\n')),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),

                      // Product cards
                      ...products.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              // Convert the parsed product info to a Product object
                              final productModel = Product(
                                id: product.id ?? 'default_id',
                                name: product.name,
                                description:
                                    product.description ??
                                    'No description available',
                                price: _parsePrice(product.price ?? '0'),
                                discountAmount: _parseDiscount(
                                  product.price ?? '0',
                                ),
                                imageUrls:
                                    product.imageUrl != null
                                        ? [product.imageUrl!]
                                        : [],
                                recipientType: [],
                                occasion: [],
                                stock: 100, // Default stock value
                                isOnSale:
                                    product.price != null &&
                                    product.price!.contains('\$'),
                                category: 'General', // Default category
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsWidget(
                                        product: productModel,
                                        userId: userId,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        product.imageUrl!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 120,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (product.price != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              product.price!,
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (product.description != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              product.description!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        if (product.url != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: GestureDetector(
                                              onTap:
                                                  () => onProductTap(
                                                    product.url!,
                                                  ),
                                              child: Text(
                                                'View Product',
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avatarName,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse price string to double
  double _parsePrice(String priceStr) {
    try {
      // Remove any non-numeric characters except decimal point
      final numericString = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericString);
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to parse discount amount
  double? _parseDiscount(String priceStr) {
    try {
      if (priceStr.contains('\$') && priceStr.contains('(')) {
        // Example format: "\$50.00 (\$10.00 off)"
        final discountMatch = RegExp(
          r'\(.*?(\d+\.?\d*).*?\)',
        ).firstMatch(priceStr);
        if (discountMatch != null) {
          return double.parse(discountMatch.group(1)!);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<ProductInfo> _parseProductRecommendations(String message) {
    final products = <ProductInfo>[];
    final lines = message.split('\n');

    ProductInfo? currentProduct;
    String? currentSection;

    for (final line in lines) {
      // Check for product header (e.g., "1. **Product Name** ($price)")
      final productHeaderMatch = RegExp(
        r'^\d+\. \*\*(.+?)\*\* \((.+?)\)',
      ).firstMatch(line);
      if (productHeaderMatch != null) {
        // Save previous product if exists
        if (currentProduct != null) {
          products.add(currentProduct);
        }

        currentProduct = ProductInfo(
          name: productHeaderMatch.group(1)!,
          price: productHeaderMatch.group(2),
        );
        currentSection = 'header';
        continue;
      }

      // Check for image URL
      final imageMatch = RegExp(r'!\[Image\]\((.+?)\)').firstMatch(line);
      if (imageMatch != null && currentProduct != null) {
        currentProduct = currentProduct.copyWith(imageUrl: imageMatch.group(1));
        continue;
      }

      // Check for product URL
      final urlMatch = RegExp(r'\[View Product\]\((.+?)\)').firstMatch(line);
      if (urlMatch != null && currentProduct != null) {
        currentProduct = currentProduct.copyWith(url: urlMatch.group(1));
        continue;
      }

      // Check for product ID (if available)
      final idMatch = RegExp(r'id:([a-f0-9]+)').firstMatch(line);
      if (idMatch != null && currentProduct != null) {
        currentProduct = currentProduct.copyWith(id: idMatch.group(1));
        continue;
      }

      // Handle description (lines that don't match any other pattern)
      if (currentProduct != null &&
          line.trim().isNotEmpty &&
          !line.startsWith('!') &&
          !line.startsWith('[') &&
          currentSection == 'header') {
        currentProduct = currentProduct.copyWith(description: line.trim());
      }
    }

    // Add the last product if exists
    if (currentProduct != null) {
      products.add(currentProduct);
    }

    return products;
  }
}

class ProductInfo {
  final String name;
  final String? price;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? id;

  ProductInfo({
    required this.name,
    this.price,
    this.description,
    this.url,
    this.imageUrl,
    this.id,
  });

  ProductInfo copyWith({
    String? name,
    String? price,
    String? description,
    String? url,
    String? imageUrl,
    String? id,
  }) {
    return ProductInfo(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
    );
  }
}
