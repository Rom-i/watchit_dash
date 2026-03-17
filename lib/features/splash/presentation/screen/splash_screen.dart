import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watchit_dash/core/constants/app_colors.dart';
import 'package:watchit_dash/features/home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  

  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double>   _glowAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 3), () async {
      await _fadeController.forward();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const VideosScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: ReverseAnimation(_fadeAnim), 
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, child) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withOpacity(_glowAnim.value * 0.65),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                ' Watch IT',
                style: TextStyle(
                  color: Color(0xFFF0F0F5),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}