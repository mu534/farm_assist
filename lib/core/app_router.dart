import 'package:flutter/material.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/camera_screen.dart';
import '../ui/screens/gallery_screen.dart';
import '../ui/screens/result_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/home': (context) => const HomeScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/camera': (context) => const CameraScreen(),
      '/gallery': (context) => const GalleryScreen(),
      '/result': (context) => ResultScreen(imagePath: ''),
    };
  }
}
