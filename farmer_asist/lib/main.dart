import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/providers/camera_provider.dart';
import 'package:farmer_asist/ui/services/localization_service.dart';
import 'package:farmer_asist/ui/screens/splash_screen.dart';
import 'package:farmer_asist/ui/screens/onboarding_screen.dart';
import 'package:camera/camera.dart';
import 'core/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load available cameras
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // Initialize language provider
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, LocalizationService>(
      builder: (context, languageProvider, localizationService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Farm Assist',
          theme: lightTheme,
          locale: languageProvider.currentLocale,
          supportedLocales: const [Locale('en'), Locale('am'), Locale('om')],
          localizationsDelegates: LocalizationService.localizationsDelegates,
          home: CameraInitializer(camera: camera),
          routes: {'/onboarding_screen': (context) => const OnboardingScreen()},
        );
      },
    );
  }
}

/// Widget to initialize the camera and navigate to SplashScreen
class CameraInitializer extends StatefulWidget {
  final CameraDescription camera;
  const CameraInitializer({super.key, required this.camera});

  @override
  State<CameraInitializer> createState() => _CameraInitializerState();
}

class _CameraInitializerState extends State<CameraInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    await cameraProvider.initializeCamera(widget.camera);
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const SplashScreen(); // Navigate to your splash screen after camera init
  }
}
