import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/camera_screen.dart';
import 'package:farmer_asist/ui/screens/gallery_screen.dart';
import 'package:farmer_asist/ui/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.agriculture, color: AppColors.primaryIndigo),
            const SizedBox(width: 8),
            const Text('Farm Assist', style: AppTextStyles.heading2),
          ],
        ),
        elevation: 2,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // 🌱 Take Photo
            _HomeCardButton(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🌱 Upload Photo
            _HomeCardButton(
              icon: Icons.photo_library,
              label: 'Upload Photo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GalleryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🌱 Settings
            _HomeCardButton(
              icon: Icons.settings,
              label: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HomeCardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        backgroundColor: Colors.white,
        shadowColor: AppColors.shadowColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.accentEmerald, width: 1.5),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryIndigo, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
