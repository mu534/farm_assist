import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/services/localization_service.dart';
import 'package:farmer_asist/ui/screens/splash_screen.dart';
import 'package:farmer_asist/ui/screens/onboarding_screen.dart';
import 'core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Assist',
      theme: lightTheme,
      locale: languageProvider.currentLocale,
      supportedLocales: const [Locale('en'), Locale('am'), Locale('om')],
      localizationsDelegates: LocalizationService.localizationsDelegates,
      home: const SplashScreen(),
      routes: {'/onboarding_screen': (context) => const OnboardingScreen()},
    );
  }
}
