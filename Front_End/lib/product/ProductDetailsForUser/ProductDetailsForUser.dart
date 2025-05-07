// lib/pages/ProductDetailsForUser.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cadeau_project/custom/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '/custom/count_controller.dart';
import '/custom/drop_down.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/models/product_model.dart';
import 'ProductDetailsForUser_model.dart';

class ProductDetailsWidget extends StatefulWidget {
  final Product product;

  const ProductDetailsWidget({super.key, required this.product});

  @override
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {
  late ProductDetailsModel _model;
  final PageController _imageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ProductDetailsModel();
    _model.countControllerValue = 1;
  }

  @override
  void dispose() {
    _model.dispose();
    _imageController.dispose();
    super.dispose();
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
            expandedHeight: mediaQuery.size.width,
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
                        FlutterFlowIconButton(
                          buttonSize: 44,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          fillColor: Colors.black.withOpacity(0.3),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        FlutterFlowIconButton(
                          buttonSize: 44,
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                          fillColor: Colors.black.withOpacity(0.3),
                          onPressed: () {},
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
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: theme.primary,
                            dotColor: Colors.white.withOpacity(0.5),
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
              padding: const EdgeInsets.all(16),
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
                          style: theme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (product.isOnSale == true &&
                              product.discountAmount != null)
                            Text(
                              '\$${(product.price ?? 0).toStringAsFixed(2)}',
                              style: theme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          Text(
                            '\$${(product.discountedPrice ?? product.price ?? 0).toStringAsFixed(2)}',
                            style: theme.headlineSmall?.copyWith(
                              color: theme.primary,
                              fontWeight: FontWeight.bold,
                            ),
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
                                style: theme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // --- TAGS ---
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...?product.recipientType?.map(
                        (type) => Chip(
                          label: Text(type),
                          backgroundColor: theme.secondaryBackground,
                          labelStyle: theme.labelSmall,
                        ),
                      ),
                      ...?product.occasion?.map(
                        (occ) => Chip(
                          label: Text(occ),
                          backgroundColor: theme.secondaryBackground,
                          labelStyle: theme.labelSmall,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- DESCRIPTION ---
                  Text(
                    'Description',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description, style: theme.bodyMedium),

                  const SizedBox(height: 24),

                  // --- OPTIONS ---
                  Text(
                    'Options',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Color',
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlutterFlowDropDown<String>(
                    controller:
                        _model.dropDownValueController1 ??= FormFieldController(
                          null,
                        ),
                    options: const ['Black', 'White', 'Blue', 'Red', 'Green'],
                    onChanged:
                        (val) => setState(() => _model.dropDownValue1 = val),
                    hintText: 'Select Color',
                    width: double.infinity,
                    height: 50,
                    textStyle: theme.bodyMedium,
                    fillColor: theme.secondaryBackground,
                    borderColor: theme.alternate,
                    borderWidth: 2,
                    borderRadius: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 2,
                    hidesUnderline: true,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Size',
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlutterFlowDropDown<String>(
                    controller:
                        _model.dropDownValueController2 ??= FormFieldController(
                          null,
                        ),
                    options: const ['S', 'M', 'L', 'XL', 'XXL'],
                    onChanged:
                        (val) => setState(() => _model.dropDownValue2 = val),
                    hintText: 'Select Size',
                    width: double.infinity,
                    height: 50,
                    textStyle: theme.bodyMedium,
                    fillColor: theme.secondaryBackground,
                    borderColor: theme.alternate,
                    borderWidth: 2,
                    borderRadius: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 2,
                    hidesUnderline: true,
                  ),

                  const SizedBox(height: 24),

                  // --- QUANTITY ---
                  Text(
                    'Quantity',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        Text('Quantity', style: theme.bodyMedium),
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
                              (val) =>
                                  Text(val.toString(), style: theme.bodyLarge),
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
                        ),
                        const SizedBox(width: 12),
                        Text(
                          product.stock > 0
                              ? '${product.stock} available in stock'
                              : 'Out of stock',
                          style: theme.bodyMedium?.copyWith(
                            color:
                                product.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
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
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            style: theme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
