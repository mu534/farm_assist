import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ChangeNotifier] that holds the current [Locale]
/// and notifies listeners whenever it changes.
class LanguageProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'selected_language_code';

  /// The currently selected locale.
  Locale _currentLocale = const Locale('en');

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;

  /// Change the app’s language and persist the choice.
  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  /// Load the saved language from local storage (defaults to English).
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageCodeKey);

    if (savedCode != null && savedCode.isNotEmpty) {
      _currentLocale = Locale(savedCode);
      notifyListeners();
    }
  }
}
