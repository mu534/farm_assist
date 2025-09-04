import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onLanguageSelected(BuildContext context, String languageCode) {
    // Save the selected language here if needed
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration Image
              Container(
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  'assets/images/farmer_illustration.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // Welcome Text
              Text(
                'Welcome to Farmer Assist',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Select your preferred language to get started',
                style: AppTextStyles.bodyTextLight,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // English Button
              ElevatedButton(
                onPressed: () => _onLanguageSelected(context, 'en'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'English',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Amharic Button (example)
              ElevatedButton(
                onPressed: () => _onLanguageSelected(context, 'am'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Amharic',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Oromo Button (example)
              ElevatedButton(
                onPressed: () => _onLanguageSelected(context, 'om'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentEmerald,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Oromo',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
