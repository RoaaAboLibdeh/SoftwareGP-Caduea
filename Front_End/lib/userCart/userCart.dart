import 'package:cadeau_project/Categories/ListCategories.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';

import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'userCart_model.dart';
export 'userCart_model.dart';

class CartWidget extends StatefulWidget {
  final String userId; // Add userId parameter

  const CartWidget({super.key, required this.userId});

  static String routeName = 'cart';
  static String routePath = '/cart';

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;
  int _currentIndex = 2;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
  }

  // Bottom Navigation Items (like SHEIN)
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(
        Icons.home,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(
        Icons.category,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Categories',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      activeIcon: Icon(
        Icons.shopping_cart,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Cart',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outlined),
      activeIcon: Icon(
        Icons.person,
        color: Color(0xFF6F61EF),
      ), // Active icon color
      label: 'Me',
    ),
  ];

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF1F5F8),
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F5F8),
          automaticallyImplyLeading: false,
          title: Text(
            'My Cart',
            style: FlutterFlowTheme.of(context).displaySmall.override(
              fontFamily: 'Outfit',
              color: Color(0xFF15161E),
              fontSize: 17,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                      child: Text(
                        'Below are the items in your cart.',
                        style: FlutterFlowTheme.of(
                          context,
                        ).labelMedium.override(
                          fontFamily: 'Outfit',
                          color: Color(0xFF57636C),
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(
                                context,
                              ).labelMedium.fontStyle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              8,
                              16,
                              0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x320E151B),
                                    offset: Offset(0.0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12,
                                  8,
                                  8,
                                  8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Hero(
                                      tag: 'ControllerImage',
                                      transitionOnUserGestures: true,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          'https://static.nike.com/a/images/t_prod_ss/w_640,c_limit,f_auto/95c8dcbe-3d3f-46a9-9887-43161ef949c5/sleepers-of-the-week-release-date.jpg',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          12,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    0,
                                                    0,
                                                    8,
                                                  ),
                                              child: Text(
                                                'AirMax Low',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).titleLarge.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,

                                                  color: Color(0xFF0F1113),
                                                  fontSize: 18,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\$120.00',
                                              style: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.fontStyle,

                                                color: Color(0xFF57636C),
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    8,
                                                    0,
                                                    0,
                                                  ),
                                              child: Text(
                                                'Quanity: 1',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).labelSmall.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,

                                                  color: Color(0xFF57636C),
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF57636C),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDE4C62),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              8,
                              16,
                              0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x320E151B),
                                    offset: Offset(0.0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12,
                                  8,
                                  8,
                                  8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Hero(
                                      tag: 'ControllerImage',
                                      transitionOnUserGestures: true,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/7c5678f4-c28d-4862-a8d9-56750f839f12/zion-1-basketball-shoes-bJ0hLJ.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          12,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    0,
                                                    0,
                                                    8,
                                                  ),
                                              child: Text(
                                                'Zion 1',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).titleLarge.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,

                                                  color: Color(0xFF0F1113),
                                                  fontSize: 18,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\$120.00',
                                              style: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.fontStyle,

                                                color: Color(0xFF57636C),
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    8,
                                                    0,
                                                    0,
                                                  ),
                                              child: Text(
                                                'Quanity: 1',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).labelSmall.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,

                                                  color: Color(0xFF57636C),
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF57636C),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDE4C62),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16,
                              8,
                              16,
                              0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x320E151B),
                                    offset: Offset(0.0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  12,
                                  8,
                                  8,
                                  8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Hero(
                                      tag: 'ControllerImage',
                                      transitionOnUserGestures: true,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,b_rgb:f5f5f5/c639068c-ee02-493b-83a1-630885f45fb0/therma-mens-full-zip-training-hoodie-DwfKtF.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          12,
                                          0,
                                          0,
                                          0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    0,
                                                    0,
                                                    8,
                                                  ),
                                              child: Text(
                                                'Jumpsuit',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).titleLarge.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleLarge.fontStyle,

                                                  color: Color(0xFF0F1113),
                                                  fontSize: 18,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\$120.00',
                                              style: FlutterFlowTheme.of(
                                                context,
                                              ).labelMedium.override(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.fontStyle,

                                                color: Color(0xFF57636C),
                                                fontSize: 14,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    8,
                                                    0,
                                                    0,
                                                  ),
                                              child: Text(
                                                'Quanity: 1',
                                                style: FlutterFlowTheme.of(
                                                  context,
                                                ).labelSmall.override(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).labelSmall.fontStyle,

                                                  color: Color(0xFF57636C),
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF57636C),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDE4C62),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24,
                              16,
                              24,
                              4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Price Breakdown',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).bodyMedium.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.fontStyle,

                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24,
                              8,
                              24,
                              0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Base Price',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).labelMedium.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.fontStyle,

                                    color: Color(0xFF57636C),
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                Text(
                                  '\$120.00',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).bodyLarge.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).bodyLarge.fontStyle,

                                    color: Color(0xFF0F1113),
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24,
                              8,
                              24,
                              0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Taxes',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).labelMedium.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.fontStyle,

                                    color: Color(0xFF57636C),
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                Text(
                                  '\$12.25',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).bodyLarge.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).bodyLarge.fontStyle,

                                    color: Color(0xFF0F1113),
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24,
                              4,
                              24,
                              12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Total',
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.fontStyle,

                                        color: Color(0xFF57636C),
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30,
                                      borderWidth: 1,
                                      buttonSize: 36,
                                      icon: Icon(
                                        Icons.info_outlined,
                                        color: Color(0xFF57636C),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$137.75',
                                  style: FlutterFlowTheme.of(
                                    context,
                                  ).displaySmall.override(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).displaySmall.fontStyle,

                                    color: Color(0xFF0F1113),
                                    fontSize: 32,
                                    letterSpacing: 0.0,
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
            ),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF827AE1),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x320E151B),
                    offset: Offset(0.0, -2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              alignment: AlignmentDirectional(0, 0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                child: Text(
                  'Checkout (\$137.75)',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,

                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
          ],
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
                      builder:
                          (context) => CategoriesPage(userId: widget.userId),
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
      ),
    );
  }
}
