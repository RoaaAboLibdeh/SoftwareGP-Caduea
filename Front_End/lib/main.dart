import 'dart:ui';
import 'package:cadeau_project/custom/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'welcome_page_model.dart';

import 'Sign_login/Authentication.dart';
export 'Sign_login/Authentication.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadeau Store',
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      home: WelcomePageWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomePageWidget extends StatelessWidget {
  const WelcomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      body: Stack(
        children: [
          // Soft background circles
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF998BCF).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Elegant circular gift display
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF998BCF).withOpacity(0.3),
                        width: 8,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/gift1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Creative "Cadeau" text treatment
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: FlutterFlowTheme.of(
                            context,
                          ).headlineMedium.override(
                            fontSize: 24,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7B6DB7),
                          ),
                        ),
                        TextSpan(
                          text: 'Cadeau',
                          style: GoogleFonts.dancingScript(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF998BCF),
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Where every gift tells a story!',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontSize: 16,
                      fontFamily: 'Outfit',
                      color: const Color(0xFF7B6DB7).withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageWidget(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF998BCF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF998BCF).withOpacity(0.4),
                    ),
                    child: Text(
                      'Begin the Journey',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign in prompt
                  TextButton(
                    onPressed: () {
                      // Navigate to sign in
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF998BCF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
