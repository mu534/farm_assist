import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static Future<Map<String, dynamic>> loadJson(String locale) async {
    final data = await rootBundle.loadString(
      'lib/core/localization/$locale.json',
    );
    return json.decode(data);
  }
}
