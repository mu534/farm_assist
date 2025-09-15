import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/services/localization_service.dart';
import 'package:farmer_asist/ui/screens/splash_screen.dart';
import 'package:farmer_asist/ui/screens/onboarding_screen.dart';


import 'core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LanguageProvider and load saved language
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
         ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, LocalizationService>(
      builder: (context, languageProvider, localizationService, child) {
        // Update localizationService with the current language
        localizationService.changeLocale(languageProvider.currentLocale.languageCode);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Farm Assist',
          theme: lightTheme,
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'), // fallback for Material widgets
            Locale('am'),
            Locale('om'), // your custom translations
          ],
          localizationsDelegates: LocalizationService.localizationsDelegates,
          localeResolutionCallback: (locale, supportedLocales) {
            // Fallback 'om' to 'en' for Flutter widgets
            if (locale != null && locale.languageCode == 'om') {
              return const Locale('en');
            }
            // Return the selected locale if supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            // Default fallback
            return const Locale('en');
          },
          home: const SplashScreen(),
          routes: {
            '/onboarding_screen': (context) => const OnboardingScreen(),
          },
        );
      },
    );
  }
}
