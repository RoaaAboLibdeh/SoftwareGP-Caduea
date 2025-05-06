import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'Sign_login/Authentication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadeau',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF998BCF),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false, // This should now work
      home: const WelcomePageWidget(),
    );
  }
}

class WelcomePageWidget extends StatefulWidget {
  const WelcomePageWidget({super.key});

  @override
  State<WelcomePageWidget> createState() => _WelcomePageWidgetState();
}

class _WelcomePageWidgetState extends State<WelcomePageWidget> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(300.ms, () => setState(() => _animate = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Animate(
            effects: [FadeEffect(duration: 1000.ms)],
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFF9F7FD), const Color(0xFFF9F7FD)],
                ),
              ),
            ),
          ),

          // Floating gift icons
          ..._buildFloatingGifts(),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    // Animated circular logo with clipped image
                    Animate(
                      effects: [
                        ScaleEffect(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.8, 0.8),
                        ),
                        FadeEffect(duration: 1000.ms),
                      ],
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF998BCF),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF998BCF).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/gift1.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 40),

                    // Welcome text
                    Animate(
                      effects: [
                        FadeEffect(duration: 600.ms),
                        SlideEffect(
                          begin: const Offset(0, 0.5),
                          duration: 800.ms,
                        ),
                      ],
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome to\n',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF998BCF),
                              ),
                            ),
                            TextSpan(
                              text: 'Cadeau',
                              style: GoogleFonts.dancingScript(
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                foreground:
                                    Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          Color(0xFF998BCF),
                                          Color(0xFFB8A8E6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                    color: Color(0xFF998BCF).withOpacity(0.5),
                                  ),
                                ],
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 12),

                    // Tagline
                    Animate(
                      effects: [FadeEffect(duration: 800.ms)],
                      child: Text(
                        'Where every gift tells a beautiful story!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color.fromARGB(
                            255,
                            79,
                            68,
                            128,
                          ).withOpacity(0.8),
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 50),

                    // Get Started Button
                    Animate(
                      effects: [
                        ScaleEffect(duration: 600.ms, curve: Curves.elasticOut),
                        FadeEffect(duration: 800.ms),
                      ],
                      child: _buildGradientButton(
                        context,
                        'Begin the Journey',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePageWidget(),
                          ),
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 20),

                    // Sign in prompt
                    Animate(
                      effects: [FadeEffect(duration: 1000.ms)],
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePageWidget(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF998BCF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingGifts() {
    return [
      Positioned(
        top: 100,
        left: 30,
        child: _buildFloatingGift(
          const Color(0xFFF9F7FD),
          Icons.card_giftcard,
          0.5,
        ),
      ),
      Positioned(
        bottom: 150,
        right: 40,
        child: _buildFloatingGift(
          const Color(0xFFF9F7FD),
          Icons.celebration,
          0.7,
        ),
      ),
      Positioned(
        top: 200,
        right: 50,
        child: _buildFloatingGift(
          const Color(0xFFF9F7FD),
          Icons.local_florist,
          0.6,
        ),
      ),
    ];
  }

  Widget _buildFloatingGift(Color color, IconData icon, double scale) {
    return Animate(
      effects: [
        ScaleEffect(
          duration: 1500.ms,
          curve: Curves.elasticOut,
          begin: Offset(scale * 0.5, scale * 0.5),
        ),
        FadeEffect(duration: 1000.ms),
      ],
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color.withOpacity(0.8), size: 30),
      ),
    ).animate(
      target: _animate ? 1 : 0,
      onPlay: (controller) => controller.repeat(reverse: true),
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF998BCF), Color(0xFFB8A8E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF998BCF).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
