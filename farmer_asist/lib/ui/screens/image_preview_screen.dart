import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String detectedDisease;
  final String recommendation;
  final String language;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    this.detectedDisease = 'Unknown Disease',
    this.recommendation = 'No recommendation yet',
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Plant Analysis'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected Disease:',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(detectedDisease, style: AppTextStyles.bodyText),
                const SizedBox(height: 16),
                Text(
                  'Recommended Treatment:',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recommendation, style: AppTextStyles.bodyText),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                    child: const Text('Back', style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
