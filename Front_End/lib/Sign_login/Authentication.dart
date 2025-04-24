import 'package:cadeau_project/Sign_login/Chooseing_Avatar.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';

import '/custom/theme.dart';
import '/custom/util.dart';
import '/custom/widgets.dart';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:provider/provider.dart';

import 'Home_page_model.dart';
export 'Home_page_model.dart';

import '/custom/drop_down.dart';

import '/custom/form_field_controller.dart';

import 'package:http/http.dart' as http;

import 'ownerThings.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.88.5:5000/api/users'; // Replace with your actual PC IP

  // Signup function
  Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      print("🟡 Sending Signup Request to: $baseUrl/signup");
      print(
        "🟡 Data: name=$name, email=$email, password=$password, role=$role",
      );

      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print("🟢 Response Status: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String userId = responseData['user']['_id'];
        print("✅ Signup successful! User ID: $userId");
        return {'userId': userId, 'message': 'Signup successful!'};
      } else {
        // Parse the error message from backend
        final errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Signup failed';

        // Return specific error type
        if (errorMessage.contains('already exists')) {
          return {'error': 'email_exists', 'message': 'Email already exists'};
        }
        return {'error': 'other_error', 'message': errorMessage};
      }
    } catch (e) {
      print("❌ Error during signup: $e");
      return {'error': 'network_error', 'message': 'Network error occurred'};
    }
  }

  // Login function
  // In AuthService class
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Return the actual error message from backend
        final errorData = jsonDecode(response.body);
        return {'error': errorData['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}

// Example usage in your Flutter app
// Update handleSignup to return the response:
Future<Map<String, dynamic>?> handleSignup(
  BuildContext context,
  String name,
  String email,
  String password,
  String role,
) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    final authService = AuthService();
    final response = await authService.signUp(name, email, password, role);

    // Close loading dialog
    Navigator.pop(context);

    if (response.containsKey('error')) {
      String errorMessage;

      // Customize message based on error type
      if (response['error'] == 'email_exists') {
        errorMessage =
            'This email is already registered. Please use a different email.';
      } else {
        errorMessage =
            response['message'] ?? 'Signup failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    } else {
      return response;
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error occurred. Please check your connection.'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}

Future<void> handleLogin(
  BuildContext context,
  String email,
  String password,
) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  try {
    final authService = AuthService();
    final response = await authService.login(email, password);

    // Close loading dialog
    Navigator.pop(context);

    if (response.containsKey('error')) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['error'].toString()),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Login successful - check role and navigate
      final userRole =
          response['user']['role'] ?? 'Customer'; // Get role from backend
      final userId = response['user']['_id'] ?? ''; // Get user ID from response

      if (userRole == 'Owner' || userRole == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OwnerThings()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    userHomePage(userId: userId), // Updated to UserHomePage
          ),
        );
      }
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog on error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/////////////////////////////////////////////////////////// connect with backend ////////////////////////////////////////////
class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/HomePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
    _model.nameSignupTextController ??= TextEditingController();
    _model.nameSignupFocusNode ??= FocusNode();

    _model.emailSigupTextController ??= TextEditingController();
    _model.emailSigupFocusNode ??= FocusNode();

    _model.passwordSignupTextController ??= TextEditingController();
    _model.passwordSignupFocusNode ??= FocusNode();

    _model.confirmpassSupTextController ??= TextEditingController();
    _model.confirmpassSupFocusNode ??= FocusNode();

    _model.emailLoginTextController ??= TextEditingController();
    _model.emailLoginFocusNode ??= FocusNode();

    _model.passLoginTextController ??= TextEditingController();
    _model.passLoginFocusNode ??= FocusNode();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF998BCF),
          automaticallyImplyLeading: false,
          title: Text(
            'Cadeau',
            style: GoogleFonts.dancingScript(
              color: Colors.white,
              fontSize: 33,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 450,
                  decoration: BoxDecoration(),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment(0, 0),
                        child: TabBar(
                          labelColor: Color(0xFF091116),
                          unselectedLabelColor:
                              FlutterFlowTheme.of(context).secondaryText,
                          labelStyle: FlutterFlowTheme.of(
                            context,
                          ).headlineSmall.override(
                            fontFamily: 'PT Sans',
                            letterSpacing: 0.0,
                          ),
                          unselectedLabelStyle: FlutterFlowTheme.of(
                            context,
                          ).headlineMedium.override(
                            fontFamily: 'Inter Tight',
                            letterSpacing: 0.0,
                          ),
                          indicatorColor: Color(0xFF998BCF),
                          tabs: [Tab(text: 'Sign up'), Tab(text: 'Log in')],
                          controller: _model.tabBarController,
                          onTap: (i) async {
                            [() async {}, () async {}][i]();
                          },
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _model.tabBarController,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: 370,
                                  child: TextFormField(
                                    controller:
                                        _model.nameSignupTextController ??
                                        TextEditingController(),
                                    focusNode:
                                        _model.nameSignupFocusNode ??
                                        FocusNode(),
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      hintText: 'Name...',
                                      hintStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        shadows: [
                                          Shadow(
                                            color: Color(0xFFF3F5F7),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          ),
                                        ],
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      filled: true,
                                      fillColor:
                                          FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMedium.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                    cursorColor:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                    validator: _model
                                        .nameSignupTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: 370,
                                  child: TextFormField(
                                    controller:
                                        _model.emailSigupTextController ??
                                        TextEditingController(),
                                    focusNode:
                                        _model.emailSigupFocusNode ??
                                        FocusNode(),
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF152435),
                                        letterSpacing: 0.0,
                                      ),
                                      hintText: 'Email...',
                                      hintStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      filled: true,
                                      fillColor:
                                          FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMedium.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                    cursorColor:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                    validator: _model
                                        .emailSigupTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: 370,
                                  child: TextFormField(
                                    controller:
                                        _model.passwordSignupTextController ??
                                        TextEditingController(),
                                    focusNode:
                                        _model.passwordSignupFocusNode ??
                                        FocusNode(),
                                    autofocus: false,
                                    obscureText:
                                        !_model.passwordSignupVisibility,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      hintText: 'Password...',
                                      hintStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      filled: true,
                                      fillColor:
                                          FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                      suffixIcon: InkWell(
                                        onTap:
                                            () => safeSetState(
                                              () =>
                                                  _model.passwordSignupVisibility =
                                                      !_model
                                                          .passwordSignupVisibility,
                                            ),
                                        focusNode: FocusNode(
                                          skipTraversal: true,
                                        ),
                                        child: Icon(
                                          _model.passwordSignupVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMedium.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                    cursorColor:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                    validator: _model
                                        .passwordSignupTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                Container(
                                  width: 370,
                                  child: TextFormField(
                                    controller:
                                        _model.confirmpassSupTextController ??
                                        TextEditingController(),
                                    focusNode:
                                        _model.confirmpassSupFocusNode ??
                                        FocusNode(),
                                    autofocus: false,
                                    obscureText:
                                        !_model.confirmpassSupVisibility,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      hintText: 'Confirm Password...',
                                      hintStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).error,
                                          width: 12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      filled: true,
                                      fillColor:
                                          FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                      suffixIcon: InkWell(
                                        onTap:
                                            () => safeSetState(
                                              () =>
                                                  _model.confirmpassSupVisibility =
                                                      !_model
                                                          .confirmpassSupVisibility,
                                            ),
                                        focusNode: FocusNode(
                                          skipTraversal: true,
                                        ),
                                        child: Icon(
                                          _model.confirmpassSupVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMedium.override(
                                      fontFamily: 'Outfit',
                                      letterSpacing: 0.0,
                                    ),
                                    textAlign: TextAlign.start,
                                    cursorColor:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).primaryText,
                                    validator: _model
                                        .confirmpassSupTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                FlutterFlowDropDown<String>(
                                  controller:
                                      _model.dropDownValueController ??=
                                          FormFieldController<String>(null),
                                  options: ['Customer', 'Owner'],
                                  onChanged:
                                      (val) => safeSetState(
                                        () => _model.dropDownValue = val,
                                      ),
                                  width: 370,
                                  height: 40,
                                  textStyle: FlutterFlowTheme.of(
                                    context,
                                  ).bodyMedium.override(
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.0,
                                  ),
                                  hintText: 'Sign up as...',
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color:
                                        FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                    size: 24,
                                  ),
                                  fillColor:
                                      FlutterFlowTheme.of(
                                        context,
                                      ).secondaryBackground,
                                  elevation: 2,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0,
                                  borderRadius: 30,
                                  margin: EdgeInsetsDirectional.fromSTEB(
                                    12,
                                    0,
                                    12,
                                    0,
                                  ),
                                  hidesUnderline: true,
                                  isOverButton: false,
                                  isSearchable: false,
                                  isMultiSelect: false,
                                ),
                                FFButtonWidget(
                                  onPressed: () async {
                                    if (_model
                                            .nameSignupTextController
                                            ?.text
                                            .isNotEmpty ??
                                        false) {
                                      final signupResponse = await handleSignup(
                                        context,
                                        _model.nameSignupTextController?.text ??
                                            '',
                                        _model.emailSigupTextController?.text ??
                                            '',
                                        _model
                                                .passwordSignupTextController
                                                ?.text ??
                                            '',
                                        _model.dropDownValue ?? 'Customer',
                                      );

                                      if (signupResponse != null &&
                                          signupResponse.containsKey(
                                            'userId',
                                          )) {
                                        // Check the user's role
                                        final role =
                                            _model.dropDownValue ?? 'Customer';

                                        if (role == 'Customer') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Chooseing_Avatar(
                                                    userId:
                                                        signupResponse['userId'],
                                                    // userName:
                                                    // signupResponse['userName'],
                                                  ),
                                            ),
                                          );
                                        } else if (role == 'Owner') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      OwnerThings(), // Replace with your Owner page
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Signup failed!'),
                                          ),
                                        );
                                      }
                                    } else {
                                      print('Controller is null or empty!');
                                    }
                                  },
                                  text: 'Sign up',
                                  options: FFButtonOptions(
                                    width: 200,
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
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Container(
                                      width: 370,
                                      child: TextFormField(
                                        controller:
                                            _model.emailLoginTextController ??
                                            TextEditingController(),
                                        focusNode:
                                            _model.emailLoginFocusNode ??
                                            FocusNode(),
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                          ),
                                          hintText: 'Email...',
                                          hintStyle: FlutterFlowTheme.of(
                                            context,
                                          ).labelMedium.override(
                                            fontFamily: 'Outfit',
                                            letterSpacing: 0.0,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).error,
                                              width: 12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).error,
                                                  width: 12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(
                                                context,
                                              ).secondaryBackground,
                                        ),
                                        style: FlutterFlowTheme.of(
                                          context,
                                        ).bodyMedium.override(
                                          fontFamily: 'Outfit',
                                          letterSpacing: 0.0,
                                        ),
                                        cursorColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).primaryText,
                                        validator: _model
                                            .emailLoginTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 370,
                                    child: TextFormField(
                                      controller:
                                          _model.passLoginTextController ??
                                          TextEditingController(),
                                      focusNode:
                                          _model.passLoginFocusNode ??
                                          FocusNode(),
                                      autofocus: false,
                                      obscureText: !_model.passLoginVisibility,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.override(
                                          fontFamily: 'Outfit',
                                          letterSpacing: 0.0,
                                        ),
                                        hintText: 'Password...',
                                        hintStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.override(
                                          fontFamily: 'Outfit',
                                          letterSpacing: 0.0,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).error,
                                            width: 12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                FlutterFlowTheme.of(
                                                  context,
                                                ).error,
                                            width: 12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor:
                                            FlutterFlowTheme.of(
                                              context,
                                            ).secondaryBackground,
                                        suffixIcon: InkWell(
                                          onTap:
                                              () => safeSetState(
                                                () =>
                                                    _model.passLoginVisibility =
                                                        !_model
                                                            .passLoginVisibility,
                                              ),
                                          focusNode: FocusNode(
                                            skipTraversal: true,
                                          ),
                                          child: Icon(
                                            _model.passLoginVisibility
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium.override(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                      cursorColor:
                                          FlutterFlowTheme.of(
                                            context,
                                          ).primaryText,
                                      validator: _model
                                          .passLoginTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        handleLogin(
                                          context,
                                          _model.emailLoginTextController.text,
                                          _model.passLoginTextController.text,
                                        );
                                      },
                                      text: 'Log in',
                                      options: FFButtonOptions(
                                        width: 200,
                                        height: 40,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          16,
                                          0,
                                          16,
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
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 35)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Join thousands of users and start your journey today!',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    letterSpacing: 0.0,
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
