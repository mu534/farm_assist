import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'selected_language_code';

  Locale _currentLocale = const Locale('en');

  LanguageProvider();

  Locale get currentLocale => _currentLocale;

  /// Change the app’s language and persist the choice.
  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  /// Public method to load the saved language
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageCodeKey);

    if (savedCode != null && savedCode.isNotEmpty) {
      _currentLocale = Locale(savedCode);
      notifyListeners();
    }
  }
}
