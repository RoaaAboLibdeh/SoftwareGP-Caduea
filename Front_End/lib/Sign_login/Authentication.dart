// ignore_for_file: unused_import, duplicate_ignore

import 'package:cadeau_project/Sign_login/Chooseing_Avatar.dart';
import 'package:cadeau_project/owner/details/menu/ownermenu_widget.dart';
import 'package:cadeau_project/owner/details/owner_details_widget.dart';
import 'package:cadeau_project/userHomePage/userHomePage.dart';
// import 'package:cadeau_project/owner/menu/ownermenu_widget.dart';
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
      'http://192.168.88.100:5000/api/users'; // Replace with your actual PC IP

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
    builder:
        (context) => Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 124, 177, 255),
          ),
        ),
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
          response['user']['role'] ?? 'customer'; // Get role from backend
      final userId = response['user']['_id'] ?? ''; // Get user ID from response

      final ownerId = response['user']['_id'];

      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OwnerDetailsWidget()),
        );
      } else if (userRole == 'Owner' || userRole == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => OwnermenuWidget(
                  ownerId: userId,
                ), // Passing dynamically fetched ownerId
          ),
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // App Logo/Title
                _buildAppHeader(),
                const SizedBox(height: 32),

                // Auth Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tabs
                      _buildAuthTabs(),
                      // Tab Content
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          controller: _model.tabBarController,
                          children: [
                            // Signup Tab
                            _buildSignupForm(),
                            // Login Tab
                            _buildLoginForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Cadeau',
          style: GoogleFonts.pacifico(
            fontSize: 38,
            fontWeight: FontWeight.w100,
            letterSpacing: 1.5,
            color: Color.fromARGB(255, 124, 177, 255),
          ),
        ),
        Text(
          'Your perfect gift companion',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAuthTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: TabBar(
        controller: _model.tabBarController,
        labelColor: Color.fromARGB(255, 124, 177, 255),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color.fromARGB(255, 124, 177, 255),
        indicatorWeight: 3,
        tabs: [
          Tab(
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tab(
            child: Text(
              'Log In',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(
            controller: _model.nameSignupTextController,
            focusNode: _model.nameSignupFocusNode,
            hintText: 'Full Name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _model.emailSigupTextController,
            focusNode: _model.emailSigupFocusNode,
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _model.passwordSignupTextController,
            focusNode: _model.passwordSignupFocusNode,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: !_model.passwordSignupVisibility,
            suffixIcon: IconButton(
              icon: Icon(
                _model.passwordSignupVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed:
                  () => setState(() {
                    _model.passwordSignupVisibility =
                        !_model.passwordSignupVisibility;
                  }),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _model.confirmpassSupTextController,
            focusNode: _model.confirmpassSupFocusNode,
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: !_model.confirmpassSupVisibility,
            suffixIcon: IconButton(
              icon: Icon(
                _model.confirmpassSupVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed:
                  () => setState(() {
                    _model.confirmpassSupVisibility =
                        !_model.confirmpassSupVisibility;
                  }),
            ),
          ),
          const SizedBox(height: 16),
          FlutterFlowDropDown<String>(
            controller:
                _model.dropDownValueController ??= FormFieldController<String>(
                  null,
                ),
            options: ['customer'],
            onChanged: (val) => safeSetState(() => _model.dropDownValue = val),
            width: double.infinity,
            height: 56,
            textStyle: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
            hintText: 'Select your role...',
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
              size: 24,
            ),
            fillColor: Colors.grey[100],
            elevation: 2,
            borderColor: Colors.transparent,
            borderWidth: 0,
            borderRadius: 12,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            hidesUnderline: true,
          ),
          const SizedBox(height: 24),
          _buildAuthButton(
            text: 'Create Account',
            onPressed: () async {
              if (_model.nameSignupTextController?.text.isNotEmpty ?? false) {
                final signupResponse = await handleSignup(
                  context,
                  _model.nameSignupTextController?.text ?? '',
                  _model.emailSigupTextController?.text ?? '',
                  _model.passwordSignupTextController?.text ?? '',
                  _model.dropDownValue ?? 'customer',
                );

                if (signupResponse != null &&
                    signupResponse.containsKey('userId')) {
                  final role = _model.dropDownValue ?? 'customer';
                  if (role == 'customer') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Chooseing_Avatar(
                              userId: signupResponse['userId'],
                            ),
                      ),
                    );
                  } else if (role == 'Owner') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerDetailsWidget(),
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(
            controller: _model.emailLoginTextController,
            focusNode: _model.emailLoginFocusNode,
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _model.passLoginTextController,
            focusNode: _model.passLoginFocusNode,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: !_model.passLoginVisibility,
            suffixIcon: IconButton(
              icon: Icon(
                _model.passLoginVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed:
                  () => setState(() {
                    _model.passLoginVisibility = !_model.passLoginVisibility;
                  }),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Add forgot password functionality
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 255, 180, 68),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAuthButton(
            text: 'Sign In',
            onPressed: () {
              handleLogin(
                context,
                _model.emailLoginTextController.text,
                _model.passLoginTextController.text,
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  if (_model.tabBarController != null) {
                    _model.tabBarController!.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 255, 180, 68),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 124, 177, 255),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 124, 177, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Column(
        children: [
          Text(
            'Join thousands of users and start your journey today!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.g_mobiledata),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.apple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[100],
      ),
      child: Icon(icon, color: Colors.grey[600]),
    );
  }
}
