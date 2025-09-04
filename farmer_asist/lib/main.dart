import 'package:farmer_asist/ui/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'ui/screens/splash_screen.dart';
import 'core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  initialize plugins here safely if needed
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Assist',
      theme: lightTheme,
      home: const SplashScreen(),
      routes: {'/onboarding_screen': (context) => const OnboardingScreen()},
    );
  }
}
