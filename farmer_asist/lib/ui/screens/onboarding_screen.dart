import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onLanguageSelected(BuildContext context, String languageCode) {
    // save selected language & navigate
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 👨‍🌾 Farmer illustration
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/images/farmer_illustration.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              // 👋 Welcome message
              const Text(
                'Welcome to Farm Assist!',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please choose your language',
                style: AppTextStyles.bodyTextLight,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 🌐 Language buttons
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryIndigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _onLanguageSelected(context, 'om'),
                        child: const Text(
                          'Afaan Oromo',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryIndigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _onLanguageSelected(context, 'am'),
                        child: const Text(
                          'Amharic',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryIndigo,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _onLanguageSelected(context, 'en'),
                        child: const Text(
                          'English',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
