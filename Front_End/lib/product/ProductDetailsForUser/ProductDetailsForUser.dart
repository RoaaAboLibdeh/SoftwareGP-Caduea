// lib/pages/ProductDetailsForUser.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadeau_project/custom/form_field_controller.dart';
import 'package:cadeau_project/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/custom/count_controller.dart';
import '/custom/drop_down.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/models/product_model.dart';
import 'ProductDetailsForUser_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductDetailsWidget extends StatefulWidget {
  final Product product;
  final String userId;

  const ProductDetailsWidget({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {
  late ProductDetailsModel _model;
  final PageController _imageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _model = ProductDetailsModel();
    _model.countControllerValue = 1;
    _fetchReviews();
  }

  @override
  void dispose() {
    _model.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // Helper method for text style
  TextStyle _textStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return FlutterFlowTheme.of(context).headlineMedium.override(
      fontFamily: 'Outfit',
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final product = widget.product;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: mediaQuery.size.width * 1.1,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _imageController,
                    itemCount: product.imageUrls?.length ?? 0,
                    itemBuilder:
                        (context, index) => CachedNetworkImage(
                          imageUrl: product.imageUrls?[index] ?? '',
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: theme.primary,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((product.imageUrls?.length ?? 0) > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _imageController,
                          count: product.imageUrls!.length,
                          effect: WormEffect(
                            activeDotColor: theme.primary,
                            dotColor: Colors.white.withOpacity(0.5),
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TITLE + PRICE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: _textStyle(context, fontSize: 22),
                          maxLines: 2,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (product.isOnSale == true &&
                              product.discountAmount != null)
                            Text(
                              '\$${(product.price ?? 0).toStringAsFixed(2)}',
                              style: _textStyle(context).copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          Text(
                            '\$${(product.discountedPrice ?? product.price ?? 0).toStringAsFixed(2)}',
                            style: _textStyle(
                              context,
                              fontSize: 18,
                            ).copyWith(color: theme.primary),
                          ),
                          if (product.isOnSale == true &&
                              product.discountAmount != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Save \$${product.discountAmount!.toStringAsFixed(2)}',
                                style: _textStyle(
                                  context,
                                  fontSize: 10,
                                ).copyWith(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 24),

                  // --- DESCRIPTION ---
                  Text('Description', style: _textStyle(context, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(
                      16,
                    ), // Add padding inside the box
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color of the box
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      product.description,
                      style: _textStyle(
                        context,
                        fontSize: 10,
                      ).copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- QUANTITY ---
                  Text('Quantity', style: _textStyle(context, fontSize: 18)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.alternate),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: _textStyle(context, fontSize: 14),
                        ),
                        FlutterFlowCountController(
                          count: _model.countControllerValue,
                          updateCount:
                              (val) => setState(
                                () => _model.countControllerValue = val,
                              ),
                          stepSize: 1,
                          minimum: 1,
                          maximum: product.stock,
                          decrementIconBuilder:
                              (enabled) => Icon(
                                Icons.remove,
                                color:
                                    enabled
                                        ? theme.primaryText
                                        : theme.secondaryText,
                              ),
                          incrementIconBuilder:
                              (enabled) => Icon(
                                Icons.add,
                                color:
                                    enabled
                                        ? theme.primaryText
                                        : theme.secondaryText,
                              ),
                          countBuilder:
                              (val) => Text(
                                val.toString(),
                                style: _textStyle(context, fontSize: 16),
                              ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- STOCK INFO ---
                  Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.alternate),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          product.stock > 0
                              ? '${product.stock} available in stock'
                              : 'Out of stock',
                          style: _textStyle(context, fontSize: 14).copyWith(
                            color:
                                product.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- REVIEWS SECTION ---
                  _buildReviewsSection(context),

                  const SizedBox(height: 24),

                  // --- ADD REVIEW SECTION ---
                  _buildAddReviewSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed:
              product.stock > 0
                  ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                  : null,
          child: Text(
            product.stock > 0
                ? 'Add to Cart - \$${((product.discountedPrice ?? product.price ?? 0) * _model.countControllerValue).toStringAsFixed(2)}'
                : 'Out of Stock',
            style: _textStyle(
              context,
              fontSize: 16,
            ).copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSection(
    BuildContext context, {
    required String title,
    required List<String> options,
    required FormFieldController<String?> controller,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _textStyle(context, fontSize: 14)),
        const SizedBox(height: 8),
        FlutterFlowDropDown<String>(
          controller: controller ??= FormFieldController(null),
          options: options,
          onChanged: onChanged,
          hintText: 'Select $title',
          width: double.infinity,
          height: 50,
          textStyle: _textStyle(context, fontSize: 14),
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          borderColor: FlutterFlowTheme.of(context).alternate,
          borderWidth: 2,
          borderRadius: 8,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 2,
          hidesUnderline: true,
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Reviews', style: _textStyle(context, fontSize: 20)),
        const SizedBox(height: 8),

        if (_isLoadingReviews) const Center(child: CircularProgressIndicator()),

        if (!_isLoadingReviews && _reviews.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                _averageRating.toStringAsFixed(1),
                style: _textStyle(context, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_reviews.length} reviews)',
                style: _textStyle(context, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._reviews
              .map(
                (review) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getInitialsColor(review.userName),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              review.nameInitial,
                              style: _textStyle(
                                context,
                                fontSize: 16,
                              ).copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userName,
                                  style: _textStyle(context, fontSize: 14),
                                ),
                                Text(
                                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                  style: _textStyle(
                                    context,
                                    fontSize: 12,
                                  ).copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review.comment,
                        style: _textStyle(
                          context,
                          fontSize: 14,
                        ).copyWith(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ] else if (!_isLoadingReviews) ...[
          Text(
            'No reviews yet',
            style: _textStyle(
              context,
              fontSize: 14,
            ).copyWith(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildAddReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Your Review', style: _textStyle(context, fontSize: 20)),
        const SizedBox(height: 16),

        Text('Your Rating', style: _textStyle(context, fontSize: 14)),
        const SizedBox(height: 8),

        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _model.userRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _model.userRating = index + 1;
                });
              },
            );
          }),
        ),

        const SizedBox(height: 16),

        Text('Your Review', style: _textStyle(context, fontSize: 14)),
        const SizedBox(height: 8),

        TextField(
          controller: _model.reviewController,
          decoration: InputDecoration(
            hintText: 'Share your experience with this product...',
            hintStyle: _textStyle(
              context,
              fontSize: 14,
            ).copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
              ),
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 4,
          style: _textStyle(
            context,
            fontSize: 14,
          ).copyWith(fontWeight: FontWeight.normal),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              final comment = _model.reviewController.text.trim();
              final rating = _model.userRating;

              if (comment.isEmpty || rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add a comment and rating'),
                  ),
                );
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse('http://192.168.88.100:5000/api/reviews'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'userId': widget.userId,
                    'productId': widget.product.id,
                    'rating': rating,
                    'comment': comment,
                  }),
                );

                if (response.statusCode == 201) {
                  _model.reviewController.clear();
                  _model.userRating = 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted successfully'),
                    ),
                  );
                  _fetchReviews();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to submit review')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text(
              'Submit Review',
              style: _textStyle(
                context,
                fontSize: 16,
              ).copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Color _getInitialsColor(String userName) {
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFEA4335), // Red
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFF673AB7), // Purple
    ];
    return colors[userName.hashCode % colors.length];
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.88.100:5000/api/reviews/products/${widget.product.id}',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> reviewsJson = decoded['data'];
        final dynamic averageRatingFromApi = decoded['averageRating'];
        double averageRating = 0.0;

        if (averageRatingFromApi is int) {
          averageRating = averageRatingFromApi.toDouble();
        } else if (averageRatingFromApi is double) {
          averageRating = averageRatingFromApi;
        }

        setState(() {
          _reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
          _averageRating = _calculateAverageRating(_reviews);
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = 0.0;
    for (var review in reviews) {
      total += review.rating.toDouble();
    }
    return total / reviews.length;
  }
}
