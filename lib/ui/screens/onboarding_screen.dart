import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/screens/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _onLanguageSelected(
    BuildContext context,
    String languageCode,
  ) async {
    // update the locale in LanguageProvider and persist it
    await context.read<LanguageProvider>().changeLanguage(languageCode);

    // then navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
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
              // Illustration
              Padding(
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  'assets/images/farmer_illustration.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

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

              _buildLanguageButton(context, 'English', 'en'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Amharic', 'am'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Oromo', 'om'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String title,
    String code,
  ) {
    return ElevatedButton(
      onPressed: () => _onLanguageSelected(context, code),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentEmerald,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        title,
        style: AppTextStyles.buttonText.copyWith(color: Colors.white),
      ),
    );
  }
}
