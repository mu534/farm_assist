import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/services/localization_service.dart';
import 'package:farmer_asist/ui/widgets/language_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Preferences', style: AppTextStyles.heading2),
          const SizedBox(height: 12),

          // Language Selector
         LanguageSelector(
  onEnglish: () async {
    await languageProvider.changeLanguage('en');
    // Use the provider instance instead of creating a new one
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    await localizationService.changeLocale('en');
  },
  onAmharic: () async {
    await languageProvider.changeLanguage('am');
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    await localizationService.changeLocale('am');
  },
  onOromo: () async {
    await languageProvider.changeLanguage('om');
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    await localizationService.changeLocale('om');
  },
),


          const SizedBox(height: 24),
          _buildCard(
            context,
            title: 'Offline Mode',
            subtitle: 'Enable or disable offline usage',
            icon: Icons.wifi_off,
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppColors.primaryIndigo,
            ),
          ),
          _buildCard(
            context,
            title: 'About App',
            subtitle: 'Version, developers & credits',
            icon: Icons.info,
            onTap: () {},
          ),
          _buildCard(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip,
            onTap: () {},
          ),
          _buildCard(
            context,
            title: 'Contact Support',
            icon: Icons.support_agent,
            onTap: () {},
          ),
          _buildCard(
            context,
            title: 'Sync Database',
            subtitle: 'Update disease & drug data',
            icon: Icons.sync,
            onTap: () {},
          ),
          _buildCard(
            context,
            title: 'Reset to Defaults',
            icon: Icons.restore,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryIndigo),
        title: Text(title, style: AppTextStyles.bodyText),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.bodyTextLight)
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
