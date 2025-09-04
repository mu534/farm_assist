import 'dart:async';

import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const splashDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    Future.delayed(splashDelay, () {
      Navigator.pushReplacementNamed(context, '/onboarding_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentEmerald,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/splash_logo.png', width: 120),
              ),
              const SizedBox(height: 20),
              Text(
                'Farmer Assist',
                style: AppTextStyles.heading1.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
