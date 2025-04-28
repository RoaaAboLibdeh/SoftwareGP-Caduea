// ignore_for_file: unused_import, unnecessary_null_comparison
import 'package:cadeau_project/owner/details/menu/ownermenu_widget.dart';

import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import '/custom/upload_data.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:cadeau_project/owner/menu/ownermenu_widget.dart';
import 'create_product_model.dart';
export 'create_product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class CreateProductWidget extends StatefulWidget {
  final String ownerId;

  const CreateProductWidget({Key? key, required this.ownerId})
    : super(key: key);

  static String routeName = 'CreateProduct';
  static String routePath = '/createProduct';

  @override
  State<CreateProductWidget> createState() => _CreateProductWidgetState();
}

Future<List<Map<String, dynamic>>> fetchCategories() async {
  final response = await http.get(
    Uri.parse('http://192.168.88.14:5000/api/categories'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List categories = data['categories'];
    return categories.map<Map<String, dynamic>>((cat) {
      return {'id': cat['_id'], 'name': cat['name']};
    }).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<List<String>> fetchCategoryNames() async {
  final response = await http.get(
    Uri.parse('http://192.168.88.14:5000/api/categories'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> categoryList = data['categories'];
    return categoryList.map<String>((cat) => cat['name'].toString()).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

class _CreateProductWidgetState extends State<CreateProductWidget> {
  late CreateProductModel _model;
  FFUploadedFile? uploadedFile;

  List<File?> selectedImages = [null, null, null];

  String? selectedCategoryId;
  String? selectedCategory;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateProductModel());

    _model.productNameTextController ??= TextEditingController();
    _model.productNameFocusNode ??= FocusNode();

    _model.descriptionTextController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();

    _model.keyTextController ??= TextEditingController();
    _model.keyFocusNode ??= FocusNode();

    _model.minpriceTextController ??= TextEditingController();
    _model.minpriceFocusNode ??= FocusNode();

    _model.maxpriceTextController ??= TextEditingController();
    _model.maxpriceFocusNode ??= FocusNode();

    _model.dicountValue = true;
    _model.diciuntamountTextController ??= TextEditingController();
    _model.diciuntamountFocusNode ??= FocusNode();

    _model.keywordsTextController ??= TextEditingController();
    _model.keywordsFocusNode ??= FocusNode();

    _model.stockTextController ??= TextEditingController();
    _model.stockFocusNode ??= FocusNode();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    print("📷 Image selected: ${pickedFile?.path}");

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  String getMimeType(String path) {
    if (path.toLowerCase().endsWith('.png')) return 'png';
    if (path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg'))
      return 'jpeg';
    return 'jpeg'; // default fallback
  }

  Future<void> uploadProduct() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a category!')));
      return;
    }

    final uri = Uri.parse('http://192.168.88.14:5000/api/products/addproduct');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = _model.productNameTextController.text;
    request.fields['description'] = _model.descriptionTextController.text;
    request.fields['owner_id'] = widget.ownerId;
    request.fields['priceRange[min]'] = _model.minpriceTextController.text;
    request.fields['priceRange[max]'] = _model.maxpriceTextController.text;
    request.fields['stock'] = _model.stockTextController.text;
    request.fields['category'] = selectedCategoryId!;
    request.fields['price'] = _model.maxpriceTextController.text;

    // Add discount fields to the request:
    request.fields['isOnSale'] = _model.dicountValue.toString();
    request.fields['discountAmount'] = _model.diciuntamountTextController.text;
    request.fields['recipientType'] = jsonEncode(
      _model.choiceChipsValues2 ?? [],
    );
    request.fields['occasion'] = jsonEncode(_model.choiceChipsValues1 ?? []);
    request.fields['keywords'] = jsonEncode(
      _model.keywordsTextController.text.split(','),
    );

    for (var image in selectedImages.where((img) => img != null)) {
      final mimeType = getMimeType(image!.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', mimeType),
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Product created successfully!')),
      );
      setState(() {
        _model.productNameTextController?.clear();
        _model.descriptionTextController?.clear();
        _model.minpriceTextController?.clear();
        _model.maxpriceTextController?.clear();
        _model.diciuntamountTextController?.clear();
        _model.keywordsTextController?.clear();
        _model.stockTextController?.clear();
        _model.choiceChipsValues1 = [];
        _model.choiceChipsValues2 = [];
        selectedImages = [null, null, null];
        selectedCategoryId = null;
        selectedCategory = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: ${response.statusCode}')),
      );
    }
  }

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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Product',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ].divide(SizedBox(height: 4)),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
              child: FlutterFlowIconButton(
                borderColor: FlutterFlowTheme.of(context).alternate,
                borderRadius: 12,
                borderWidth: 1,
                buttonSize: 40,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                icon: Icon(
                  Icons.close_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24,
                ),
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OwnermenuWidget(ownerId: widget.ownerId),
                    ),
                  );
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                          child: Text(
                            'Fill out the information below to post a product',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(
                              context,
                            ).labelMedium.override(
                              fontFamily: 'Outfit',
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, -1),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 1270),
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                16,
                                12,
                                16,
                                0,
                              ),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                direction: Axis.horizontal,
                                runAlignment: WrapAlignment.center,
                                verticalDirection: VerticalDirection.down,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 570),
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 400,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).alternate,
                                            ),
                                          ),
                                          child: Container(
                                            width: 400,
                                            height: 200,
                                            child: Stack(
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Stack(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            child: InkWell(
                                                              splashColor:
                                                                  Colors
                                                                      .transparent,
                                                              focusColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor:
                                                                  Colors
                                                                      .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                final pickedFile =
                                                                    await ImagePicker()
                                                                        .pickImage(
                                                                          source:
                                                                              ImageSource.gallery,
                                                                        );
                                                                if (pickedFile !=
                                                                    null) {
                                                                  setState(() {
                                                                    selectedImages[0] = File(
                                                                      pickedFile
                                                                          .path,
                                                                    );
                                                                  });
                                                                }
                                                              },
                                                              child:
                                                                  selectedImages[0] !=
                                                                          null
                                                                      ? Image.file(
                                                                        selectedImages[0]!,
                                                                        width:
                                                                            115,
                                                                        height:
                                                                            200,
                                                                        fit:
                                                                            BoxFit.cover,
                                                                      )
                                                                      : Padding(
                                                                        padding: EdgeInsets.only(
                                                                          left:
                                                                              20,
                                                                        ), // 👈 shifts content to the right
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.add_box,
                                                                              color:
                                                                                  FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).primaryText,
                                                                              size:
                                                                                  24,
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  8,
                                                                            ),
                                                                            Text(
                                                                              'Add first photo',
                                                                              style: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).bodyMedium.override(
                                                                                fontFamily:
                                                                                    'Outfit',
                                                                                color:
                                                                                    FlutterFlowTheme.of(
                                                                                      context,
                                                                                    ).primaryText,
                                                                                letterSpacing:
                                                                                    0.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsetsDirectional.fromSTEB(
                                                        120,
                                                        0,
                                                        0,
                                                        0,
                                                      ),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: IntrinsicWidth(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Expanded(
                                                            child: Stack(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        4,
                                                                      ),
                                                                  child: InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () async {
                                                                      final pickedFile = await ImagePicker().pickImage(
                                                                        source:
                                                                            ImageSource.gallery,
                                                                      );
                                                                      if (pickedFile !=
                                                                          null) {
                                                                        setState(() {
                                                                          selectedImages[1] = File(
                                                                            pickedFile.path,
                                                                          );
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        selectedImages[1] !=
                                                                                null
                                                                            ? Image.file(
                                                                              selectedImages[1]!,
                                                                              width:
                                                                                  115,
                                                                              height:
                                                                                  200,
                                                                              fit:
                                                                                  BoxFit.cover,
                                                                            )
                                                                            : Padding(
                                                                              padding: EdgeInsets.only(
                                                                                left:
                                                                                    20,
                                                                              ), // 👈 adjust this value as needed
                                                                              child: Column(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.add_box,
                                                                                    color:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).primaryText,
                                                                                    size:
                                                                                        24,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height:
                                                                                        8,
                                                                                  ),
                                                                                  Text(
                                                                                    'Add the second',
                                                                                    style: FlutterFlowTheme.of(
                                                                                      context,
                                                                                    ).bodyMedium.override(
                                                                                      fontFamily:
                                                                                          'Outfit',
                                                                                      color:
                                                                                          FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).primaryText,
                                                                                      letterSpacing:
                                                                                          0.0,
                                                                                    ),
                                                                                  ),
                                                                                ],
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
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                        0,
                                                        0,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional.fromSTEB(
                                                          240,
                                                          0,
                                                          0,
                                                          0,
                                                        ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Stack(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      4,
                                                                    ),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor:
                                                                      Colors
                                                                          .transparent,
                                                                  hoverColor:
                                                                      Colors
                                                                          .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap: () async {
                                                                    final pickedFile =
                                                                        await ImagePicker().pickImage(
                                                                          source:
                                                                              ImageSource.gallery,
                                                                        );
                                                                    if (pickedFile !=
                                                                        null) {
                                                                      setState(() {
                                                                        selectedImages[2] = File(
                                                                          pickedFile
                                                                              .path,
                                                                        );
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      selectedImages[2] !=
                                                                              null
                                                                          ? Image.file(
                                                                            selectedImages[2]!,
                                                                            width:
                                                                                115,
                                                                            height:
                                                                                200,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                          : Padding(
                                                                            padding: EdgeInsets.only(
                                                                              left:
                                                                                  20,
                                                                            ), // 👈 adjust as needed
                                                                            child: Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.add_box,
                                                                                  color:
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).primaryText,
                                                                                  size:
                                                                                      24,
                                                                                ),
                                                                                SizedBox(
                                                                                  height:
                                                                                      8,
                                                                                ),
                                                                                Text(
                                                                                  'Add the third',
                                                                                  style: FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).bodyMedium.override(
                                                                                    fontFamily:
                                                                                        'Outfit',
                                                                                    color:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).primaryText,
                                                                                    letterSpacing:
                                                                                        0.0,
                                                                                  ),
                                                                                ),
                                                                              ],
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          controller:
                                              _model.productNameTextController,
                                          focusNode:
                                              _model.productNameFocusNode,
                                          autofocus: true,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Product name...',
                                            labelStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelLarge.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            hintStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            errorStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).alternate,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  16,
                                                  20,
                                                  16,
                                                  20,
                                                ),
                                          ),
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).bodyLarge.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                          cursorColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          validator: _model
                                              .productNameTextControllerValidator
                                              .asValidator(context),
                                        ),
                                        TextFormField(
                                          controller:
                                              _model.descriptionTextController,
                                          focusNode:
                                              _model.descriptionFocusNode,
                                          autofocus: true,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Description...',
                                            labelStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelLarge.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            alignLabelWithHint: true,
                                            hintStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            errorStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).alternate,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  16,
                                                  16,
                                                  16,
                                                  16,
                                                ),
                                          ),
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).bodyLarge.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                          maxLines: 9,
                                          minLines: 5,
                                          cursorColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          validator: _model
                                              .descriptionTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ].divide(SizedBox(height: 12)),
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 570),
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Category',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        FutureBuilder<
                                          List<Map<String, dynamic>>
                                        >(
                                          future: fetchCategories(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                'Error loading categories',
                                              );
                                            } else {
                                              final categories = snapshot.data!;
                                              return DropdownButtonFormField<
                                                String
                                              >(
                                                value:
                                                    selectedCategoryId ??
                                                    categories.first['id'],
                                                items:
                                                    categories.map((cat) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: cat['id'],
                                                        child: Text(
                                                          cat['name'],
                                                        ),
                                                      );
                                                    }).toList(),
                                                onChanged: (String? newId) {
                                                  setState(() {
                                                    selectedCategoryId = newId;
                                                    selectedCategory =
                                                        categories.firstWhere(
                                                          (c) =>
                                                              c['id'] == newId,
                                                        )['name'];
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Select Category',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.0,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),

                                        Text(
                                          'Category By Occasion',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        FlutterFlowChoiceChips(
                                          options: [
                                            ChipData('Birthday'),
                                            ChipData('Anniversary'),
                                            ChipData('Valentine'),
                                            ChipData('Christmas'),
                                            ChipData('Graduation'),
                                          ],
                                          onChanged:
                                              (val) => safeSetState(
                                                () =>
                                                    _model.choiceChipsValues1 =
                                                        val,
                                              ),
                                          selectedChipStyle: ChipStyle(
                                            backgroundColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).accent2,
                                            textStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                            iconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                            iconSize: 18,
                                            elevation: 0,
                                            borderColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondary,
                                            borderWidth: 2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          unselectedChipStyle: ChipStyle(
                                            backgroundColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            textStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                            iconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                            iconSize: 18,
                                            elevation: 0,
                                            borderColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).alternate,
                                            borderWidth: 2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          chipSpacing: 8,
                                          rowSpacing: 8,
                                          multiselect: true,
                                          initialized:
                                              _model.choiceChipsValues1 != null,
                                          alignment: WrapAlignment.start,
                                          controller:
                                              _model.choiceChipsValueController1 ??=
                                                  FormFieldController<
                                                    List<String>
                                                  >([]),
                                          wrapped: true,
                                        ),
                                        Text(
                                          'Recipient',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        FlutterFlowChoiceChips(
                                          options: [
                                            ChipData('Parents'),
                                            ChipData('Friends'),
                                            ChipData('Colleagues'),
                                            ChipData('Wife/Husband'),
                                            ChipData('Grandparents'),
                                            ChipData('Siblings'),
                                            ChipData('child'),
                                          ],
                                          onChanged:
                                              (val) => safeSetState(
                                                () =>
                                                    _model.choiceChipsValues2 =
                                                        val,
                                              ),
                                          selectedChipStyle: ChipStyle(
                                            backgroundColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).accent2,
                                            textStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                            iconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                            iconSize: 18,
                                            elevation: 0,
                                            borderColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondary,
                                            borderWidth: 2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          unselectedChipStyle: ChipStyle(
                                            backgroundColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                            textStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                            iconColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryText,
                                            iconSize: 18,
                                            elevation: 0,
                                            borderColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).alternate,
                                            borderWidth: 2,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          chipSpacing: 8,
                                          rowSpacing: 8,
                                          multiselect: true,
                                          initialized:
                                              _model.choiceChipsValues2 != null,
                                          alignment: WrapAlignment.start,
                                          controller:
                                              _model.choiceChipsValueController2 ??=
                                                  FormFieldController<
                                                    List<String>
                                                  >([]),
                                          wrapped: true,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Starting Price',
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        _model
                                                            .minpriceTextController,
                                                    focusNode:
                                                        _model
                                                            .minpriceFocusNode,
                                                    autofocus: true,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: '100.00 ILS',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).labelLarge.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            letterSpacing: 0.0,
                                                          ),
                                                      alignLabelWithHint: true,
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              ).labelMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      errorStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMedium.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).error,
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                          ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).alternate,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primary,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      errorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).error,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).error,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsetsDirectional.fromSTEB(
                                                            16,
                                                            16,
                                                            16,
                                                            16,
                                                          ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyLarge.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).primary,
                                                    validator: _model
                                                        .minpriceTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                  Text(
                                                    'Highest Price',
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        _model
                                                            .maxpriceTextController,
                                                    focusNode:
                                                        _model
                                                            .maxpriceFocusNode,
                                                    autofocus: true,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: '250.00 ILS',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).labelLarge.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            letterSpacing: 0.0,
                                                          ),
                                                      alignLabelWithHint: true,
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              ).labelMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      errorStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMedium.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).error,
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                          ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).alternate,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primary,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      errorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).error,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).error,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsetsDirectional.fromSTEB(
                                                            16,
                                                            16,
                                                            16,
                                                            16,
                                                          ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyLarge.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).primary,
                                                    validator: _model
                                                        .maxpriceTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ].divide(SizedBox(height: 4)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cash discount?',
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Switch.adaptive(
                                                    value: _model.dicountValue!,
                                                    onChanged: (
                                                      newValue,
                                                    ) async {
                                                      safeSetState(
                                                        () =>
                                                            _model.dicountValue =
                                                                newValue,
                                                      );
                                                    },
                                                    activeColor:
                                                        Colors
                                                            .white, // 🟢 Thumb color when ON
                                                    activeTrackColor: Color(
                                                      0xFF998BCF,
                                                    ), // 🟣 Track color when ON (your theme)
                                                    inactiveThumbColor:
                                                        Colors
                                                            .white, // ⚪ Thumb color when OFF
                                                    inactiveTrackColor: Color(
                                                      0xFFD3CCE3,
                                                    ),
                                                  ),
                                                  Text(
                                                    'dicount amount',
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        _model
                                                            .diciuntamountTextController,
                                                    focusNode:
                                                        _model
                                                            .diciuntamountFocusNode,
                                                    autofocus: true,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: '25.00 ILS',
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).labelLarge.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            letterSpacing: 0.0,
                                                          ),
                                                      alignLabelWithHint: true,
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              ).labelMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      errorStyle:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).bodyMedium.override(
                                                            fontFamily:
                                                                'Outfit',
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).error,
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                          ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).alternate,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).primary,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      errorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).error,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).error,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).secondaryBackground,
                                                      contentPadding:
                                                          EdgeInsetsDirectional.fromSTEB(
                                                            16,
                                                            16,
                                                            16,
                                                            16,
                                                          ),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyLarge.override(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                      color: Colors.black,
                                                    ),
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).primary,
                                                    validator: _model
                                                        .diciuntamountTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ].divide(SizedBox(height: 4)),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 12)),
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  16,
                                                  12,
                                                  16,
                                                  12,
                                                ),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                if (selectedCategoryId ==
                                                    null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Please select a category!',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                if (selectedImages.isEmpty) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Please add at least one image!',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                print('Button pressed ...');
                                                await uploadProduct();
                                                print('Button pressed ...');
                                              },
                                              text: 'Create Product',
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                height: 48,
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      24,
                                                      0,
                                                      24,
                                                      0,
                                                    ),
                                                iconPadding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                color: Color(0xFF998BCF),
                                                textStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.white,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          'Keywords',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextFormField(
                                          controller:
                                              _model.keywordsTextController,
                                          focusNode: _model.keywordsFocusNode,
                                          autofocus: true,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Write keywords sperated by ,',
                                            labelStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelLarge.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            alignLabelWithHint: true,
                                            hintStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            errorStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).alternate,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  16,
                                                  16,
                                                  16,
                                                  16,
                                                ),
                                          ),
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).bodyLarge.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                          minLines: 1,
                                          cursorColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          validator: _model
                                              .keywordsTextControllerValidator
                                              .asValidator(context),
                                        ),
                                        Text(
                                          'Stock',
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextFormField(
                                          controller:
                                              _model.stockTextController,
                                          focusNode: _model.stockFocusNode,
                                          autofocus: true,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Available Stock',
                                            labelStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelLarge.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            alignLabelWithHint: true,
                                            hintStyle: FlutterFlowTheme.of(
                                              context,
                                            ).labelMedium.override(
                                              fontFamily: 'Outfit',
                                              letterSpacing: 0.0,
                                            ),
                                            errorStyle: FlutterFlowTheme.of(
                                              context,
                                            ).bodyMedium.override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).alternate,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).secondaryBackground,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  16,
                                                  16,
                                                  16,
                                                  16,
                                                ),
                                          ),
                                          style: FlutterFlowTheme.of(
                                            context,
                                          ).bodyLarge.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                          minLines: 1,
                                          cursorColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).primary,
                                          validator: _model
                                              .StockTextControllerValidator.asValidator(
                                            context,
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (responsiveVisibility(
                  context: context,
                  tabletLandscape: false,
                  desktop: false,
                ))
                  Container(
                    constraints: BoxConstraints(maxWidth: 770),
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (selectedCategoryId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a category!'),
                              ),
                            );
                            return;
                          }

                          if (selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please add at least one image!'),
                              ),
                            );
                            return;
                          }
                          print('Button pressed ...');
                          await uploadProduct();
                        },
                        text: 'Create Product',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48,
                          padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            0,
                            0,
                          ),
                          color: Color(0xFF998BCF),
                          textStyle: FlutterFlowTheme.of(
                            context,
                          ).titleSmall.override(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                          elevation: 3,
                          borderSide: BorderSide(
                            color: Color(0xFF998BCF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
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
  }
}
