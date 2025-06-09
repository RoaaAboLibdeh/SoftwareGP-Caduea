import 'package:cadeau_project/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'Sign_login/Authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishablekey;
  await Stripe.instance.applySettings();
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
          seedColor: const Color.fromARGB(255, 124, 177, 255),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
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
    final blueColor = const Color.fromARGB(255, 124, 177, 255);
    final orangeColor = const Color.fromARGB(255, 255, 180, 68);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Simple white background with subtle decorative elements
          Positioned.fill(
            child: Animate(
              effects: [FadeEffect(duration: 1000.ms)],
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: _DotsPainter(blueColor.withOpacity(0.05)),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with Lottie animation
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
                          boxShadow: [
                            BoxShadow(
                              color: blueColor.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          'assets/logo.json',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 40),

                    // App name and tagline
                    Animate(
                      effects: [
                        FadeEffect(duration: 600.ms),
                        SlideEffect(
                          begin: const Offset(0, 0.5),
                          duration: 800.ms,
                        ),
                      ],
                      child: Column(
                        children: [
                          Text(
                            'Cadeau',
                            style: GoogleFonts.pacifico(
                              fontSize: 48,
                              fontWeight: FontWeight.w100,
                              letterSpacing: 1.5,
                              color: blueColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Where every gift tells a story!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ).animate(target: _animate ? 1 : 0),

                    const SizedBox(height: 60),

                    // Primary action button
                    Animate(
                      effects: [
                        ScaleEffect(duration: 600.ms, curve: Curves.elasticOut),
                        FadeEffect(duration: 800.ms),
                      ],
                      child: _buildSolidButton(
                        context,
                        'Start Shopping',
                        blueColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePageWidget(),
                          ),
                        ),
                      ),
                    ).animate(target: _animate ? 1 : 0),
                    const SizedBox(height: 20),

                    // Secondary action
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
                          'Sign In / Register',
                          style: GoogleFonts.poppins(
                            color: orangeColor,
                            fontWeight: FontWeight.w600,
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

  Widget _buildGradientButton(
    BuildContext context,
    String text,
    Color startColor,
    Color endColor,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color dotColor;

  _DotsPainter(this.dotColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const spacing = 60.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildSolidButton(
  BuildContext context,
  String text,
  Color color,
  VoidCallback onPressed,
) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
