// ignore_for_file: unused_import

import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cadeau_project/product/create_product_widget.dart';
import 'ownermenu_model.dart';
export 'ownermenu_model.dart';

class OwnermenuWidget extends StatefulWidget {
  final String ownerId;

  const OwnermenuWidget({Key? key, required this.ownerId}) : super(key: key);

  @override
  _OwnermenuWidgetState createState() => _OwnermenuWidgetState();
}

class _OwnermenuWidgetState extends State<OwnermenuWidget> {
  Map<String, dynamic>? ownerData;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  String ownerName = '';
  @override
  void initState() {
    super.initState();
    fetchOwnerData();
  }

  Future<void> fetchOwnerData() async {
    final url = 'http://192.168.88.12:5000/api/owners/get/${widget.ownerId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          ownerData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch owner data: $e");
    }
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Color(0xFF998BCF),
            automaticallyImplyLeading: false,
            title: Text(
              'Cadeau',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 30,
                letterSpacing: 0.0,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 2,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).accent1,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          FontAwesomeIcons.userShield,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child:
                        isLoading || ownerData == null
                            ? CircularProgressIndicator()
                            : Text(
                              ownerData!['name'],
                              style: FlutterFlowTheme.of(
                                context,
                              ).headlineSmall.override(
                                fontFamily: 'Inter Tight',
                                letterSpacing: 0.0,
                              ),
                            ),
                  ),
                  Divider(
                    height: 44,
                    thickness: 1,
                    indent: 24,
                    endIndent: 24,
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.person,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24,
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                print('Buttonprofile pressed ...');
                              },
                              text: 'Profile',
                              options: FFButtonOptions(
                                width: 300,
                                height: 40,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  0,
                                ),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  letterSpacing: 0.0,
                                ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                8,
                                0,
                                0,
                                0,
                              ),
                              child: Icon(
                                Icons.production_quantity_limits,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24,
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CreateProductWidget(
                                          ownerId: widget.ownerId,
                                        ),
                                  ),
                                );
                                print('ButtonnewPro pressed ...');
                              },
                              text: 'Add new product',
                              options: FFButtonOptions(
                                width: 300,
                                height: 40,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  0,
                                ),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  letterSpacing: 0.0,
                                ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                8,
                                0,
                                0,
                                0,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.productHunt,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24,
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                print('ButtonYpro pressed ...');
                              },
                              text: 'Edit your products',
                              options: FFButtonOptions(
                                width: 300,
                                height: 40,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  0,
                                ),
                                color: Colors.white,
                                textStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  letterSpacing: 0.0,
                                ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
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
