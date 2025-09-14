import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:farmer_asist/ui/providers/language_provider.dart';
import 'package:farmer_asist/ui/services/localization_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            languageProvider.changeLanguage('en');
            await LocalizationService().load(const Locale('en'));
          },
          child: const Text('EN'),
        ),
        TextButton(
          onPressed: () async {
            languageProvider.changeLanguage('am');
            await LocalizationService().load(const Locale('am'));
          },
          child: const Text('AM'),
        ),
        TextButton(
          onPressed: () async {
            languageProvider.changeLanguage('om');
            await LocalizationService().load(const Locale('om'));
          },
          child: const Text('OR'),
        ),
      ],
    );
  }
}
