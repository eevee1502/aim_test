import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/services/local_storage_service.dart';
import '../core/theme/aim_color.dart';
import 'home/home_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundColor = ColorTween(
      begin: AimColors.primary,
      end: Colors.white,
    ).animate(_controller);

    Future.delayed(const Duration(milliseconds: 1500), () async {
      await _controller.forward();
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    final localStorage = LocalStorageService();
    final String? userId = await localStorage.getData("user_id");

    if (mounted) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => (userId != null && userId.isNotEmpty) ? const HomeScreen() : const SignUpScreen(),
      //   ),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen()
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Center(
            child: SvgPicture.asset(
              "assets/images/logo.svg",
              height: 48,
            ),
          ),
        );
      },
    );
  }
}
