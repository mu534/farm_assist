import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import your language maps
import 'package:farmer_asist/core/localization/en.dart';
import 'package:farmer_asist/core/localization/am.dart';
import 'package:farmer_asist/core/localization/om.dart';

class LocalizationService extends ChangeNotifier {
  // Default locale
  Locale _currentLocale = const Locale('en');

  // Holds the current localized strings
  Map<String, String> _localizedStrings = en;

  Locale get currentLocale => _currentLocale;

  // Standard Flutter localization delegates
  static final localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Get localized string by key
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// Change the locale dynamically
  Future<void> changeLocale(String languageCode) async {
    _currentLocale = Locale(languageCode);

    switch (languageCode) {
      case 'am':
        _localizedStrings = am;
        break;
      case 'om':
        _localizedStrings = om;
        break;
      default:
        _localizedStrings = en;
    }

    notifyListeners();
  }
}
