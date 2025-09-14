import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  // Holds loaded localized strings
  Map<String, String> _localizedStrings = {};

  Locale get currentLocale => _currentLocale;

  // Standard Flutter localization delegates
  static final localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // Initialize localization for a specific locale
  Future<void> load(Locale locale) async {
    _currentLocale = locale;

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/core/localization/${locale.languageCode}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading localization: $e');
      }
    }
  }

  // Get the localized string by key
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Change the current locale
  Future<void> changeLocale(Locale locale) async {
    await load(locale);
  }
}
