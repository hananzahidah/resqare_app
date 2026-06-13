import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/constant/app_image.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/intro/on_boarding_screen.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 4));
    if (!mounted) return;
    if (PreferenceHandler.isLogin) {
      context.pushAndRemoveAll(BottomNavigator());
    } else {
      context.pushAndRemoveAll(OnBoardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, Color(0xFF0019BB)],
          ),
        ),
        child: Stack(
          children: [
            // Background paw prints
            Positioned(
              top: 80,
              left: 20,
              child: Icon(
                Icons.pets,
                size: 100,
                color: Colors.white.withOpacity(0.05),
              ),
            ),

            Positioned(
              top: 180,
              right: 30,
              child: Icon(
                Icons.favorite,
                size: 70,
                color: Colors.white.withOpacity(0.04),
              ),
            ),

            Positioned(
              bottom: 120,
              right: 20,
              child: Icon(
                Icons.pets,
                size: 90,
                color: Colors.white.withOpacity(0.05),
              ),
            ),

            Positioned(
              bottom: 220,
              left: 30,
              child: Icon(
                Icons.favorite,
                size: 60,
                color: Colors.white.withOpacity(0.04),
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppImages.logoWhite, width: 140, height: 140),

                  const SizedBox(height: 20),

                  const Text(
                    'ResQare',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Rescue. Care. Save Lives.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
