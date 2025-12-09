import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/app_routes.dart';

/// 스플래시 스크린
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 2초 대기
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 온보딩 완료 여부 확인
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // 다음 화면으로 이동
    if (onboardingCompleted) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboardingLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.4; // 화면 너비의 40%

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: logoWidth,
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

