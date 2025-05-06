// ignore_for_file: unused_import

import 'package:cadeau_project/main.dart';

import '../../userHomePage/userHomePage.dart';
import '/custom/choice_chips.dart';
import '/custom/icon_button.dart';
import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';
import '/custom/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import 'owner_details_model.dart';
export 'owner_details_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnerDetailsWidget extends StatefulWidget {
  const OwnerDetailsWidget({super.key});

  static String routeName = 'owner_details';
  static String routePath = '/ownerDetails';

  @override
  State<OwnerDetailsWidget> createState() => _OwnerDetailsWidgetState();
}

class _OwnerDetailsWidgetState extends State<OwnerDetailsWidget> {
  late OwnerDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OwnerDetailsModel());

    _model.idTextController ??= TextEditingController();
    _model.idFocusNode ??= FocusNode();
    _model.idFocusNode!.addListener(() => safeSetState(() {}));
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.emailFocusNode!.addListener(() => safeSetState(() {}));
    _model.idnumTextController ??= TextEditingController();
    _model.idnumFocusNode ??= FocusNode();
    _model.idnumFocusNode!.addListener(() => safeSetState(() {}));
    _model.ageTextController ??= TextEditingController();
    _model.ageFocusNode ??= FocusNode();
    _model.ageFocusNode!.addListener(() => safeSetState(() {}));
    _model.phoneNumberTextController ??= TextEditingController();
    _model.phoneNumberFocusNode ??= FocusNode();
    _model.phoneNumberFocusNode!.addListener(() => safeSetState(() {}));
    _model.dateOfBirthTextController ??= TextEditingController();
    _model.dateOfBirthFocusNode ??= FocusNode();
    _model.dateOfBirthFocusNode!.addListener(() => safeSetState(() {}));
    _model.descriptionTextController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
    _model.descriptionFocusNode!.addListener(() => safeSetState(() {}));
    _model.passTextController ??= TextEditingController();
    _model.passFocusNode ??= FocusNode();
    _model.passFocusNode!.addListener(() => safeSetState(() {}));
    _model.confirnpassTextController ??= TextEditingController();
    _model.confirnpassFocusNode ??= FocusNode();
    _model.confirnpassFocusNode!.addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _addOwner() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Prepare the data
      final ownerData = {
        'name': _model.idTextController.text,
        'email': _model.emailTextController.text,
        'password': _model.passTextController.text,
        'idNumber': _model.idnumTextController.text,
        'age': int.parse(_model.ageTextController.text),
        'phoneNumber': _model.phoneNumberTextController.text,
        'dateOfBirth': _model.dateOfBirthTextController.text,
        'description': _model.descriptionTextController.text,
        'gender': _model.choiceChipsValue ?? 'Female',
      };

      // 2. Validate passwords match
      if (_model.passTextController.text !=
          _model.confirnpassTextController.text) {
        throw Exception('Passwords do not match!');
      }

      // 3. Make API call
      final response = await http.post(
        Uri.parse(
          'http://192.168.88.17:5000/api/owners/add',
        ), // Use your backend IP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ownerData),
      );

      // Remove loading
      Navigator.pop(context);
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      // 4. Handle response
      if (response.statusCode == 201) {
        // Success - navigate back to admin dashboard

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OwnerDetailsWidget()),
        );
      } else {
        // Show error from backend
        try {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Unknown error')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Remove loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Owner information',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePageWidget(),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0, -1),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 770),
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                16,
                                12,
                                16,
                                0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                      Text(
                                        'Please fill out the form below to continue.',
                                        style: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.override(
                                          fontFamily: 'Inter',
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _model.idTextController,
                                        focusNode: _model.idFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'name',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model.idFocusNode?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                        ).titleSmall.override(
                                          fontFamily: 'Inter Tight',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .idTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      TextFormField(
                                        controller: _model.emailTextController,
                                        focusNode: _model.emailFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'email',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .emailFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .emailTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      TextFormField(
                                        controller: _model.idnumTextController,
                                        focusNode: _model.idnumFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Id number',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .idnumFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                        ).titleSmall.override(
                                          fontFamily: 'Inter Tight',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .idnumTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      TextFormField(
                                        controller: _model.ageTextController,
                                        focusNode: _model.ageFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Age',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model.ageFocusNode?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .ageTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      TextFormField(
                                        controller:
                                            _model.phoneNumberTextController,
                                        focusNode: _model.phoneNumberFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Phone number',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .phoneNumberFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .phoneNumberTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      Container(decoration: BoxDecoration()),
                                      Text(
                                        'Gender',
                                        style: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.override(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF1D1E1F),
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      FlutterFlowChoiceChips(
                                        options: [
                                          ChipData('Female'),
                                          ChipData('Male'),
                                        ],
                                        onChanged:
                                            (val) => safeSetState(
                                              () =>
                                                  _model.choiceChipsValue =
                                                      val?.firstOrNull,
                                            ),
                                        selectedChipStyle: ChipStyle(
                                          backgroundColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).accent2,
                                          textStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            fontFamily: 'Inter',
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
                                        chipSpacing: 12,
                                        rowSpacing: 12,
                                        multiselect: false,
                                        alignment: WrapAlignment.start,
                                        controller:
                                            _model.choiceChipsValueController ??=
                                                FormFieldController<
                                                  List<String>
                                                >([]),
                                        wrapped: true,
                                      ),
                                      TextFormField(
                                        controller:
                                            _model.dateOfBirthTextController,
                                        focusNode: _model.dateOfBirthFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Date of birth',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .dateOfBirthFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .dateOfBirthTextControllerValidator
                                            .asValidator(context),
                                        inputFormatters: [
                                          _model.dateOfBirthMask,
                                        ],
                                      ),
                                      TextFormField(
                                        controller:
                                            _model.descriptionTextController,
                                        focusNode: _model.descriptionFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Please describe the owner...',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          alignLabelWithHint: true,
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .descriptionFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
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
                                      TextFormField(
                                        controller: _model.passTextController,
                                        focusNode: _model.passFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'password...',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model.passFocusNode?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .passTextControllerValidator
                                            .asValidator(context),
                                      ),
                                      TextFormField(
                                        controller:
                                            _model.confirnpassTextController,
                                        focusNode: _model.confirnpassFocusNode,
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'confirm password...',
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelLarge.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                          errorStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodyMedium.override(
                                            fontFamily: 'Inter',
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                            borderRadius: BorderRadius.circular(
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
                                                    BorderRadius.circular(12),
                                              ),
                                          filled: true,
                                          fillColor:
                                              (_model
                                                          .confirnpassFocusNode
                                                          ?.hasFocus ??
                                                      false)
                                                  ? FlutterFlowTheme.of(
                                                    context,
                                                  ).accent1
                                                  : FlutterFlowTheme.of(
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
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                        validator: _model
                                            .confirnpassTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ]
                                    .divide(SizedBox(height: 12))
                                    .addToEnd(SizedBox(height: 32)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 770),
                  decoration: BoxDecoration(),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.formKey.currentState!.validate()) {
                        await _addOwner();
                      }
                    },
                    text: 'Add Owner',
                    options: FFButtonOptions(
                      width: 200,
                      height: 40,
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Color(0xFF998BCF),
                      textStyle: FlutterFlowTheme.of(
                        context,
                      ).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(30),
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
