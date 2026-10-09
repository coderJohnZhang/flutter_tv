import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Locale-aware strings loaded from `locale/<code>.json`.
///
/// A missing key falls back to the bundled English file, then to the key name.
class Translations {
  const Translations(this.locale, this._values, this._fallback);

  final Locale locale;
  final Map<String, dynamic> _values;
  final Map<String, dynamic> _fallback;

  String text(String key) {
    final dynamic value = _values[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    final dynamic fallback = _fallback[key];
    return fallback is String ? fallback : key;
  }

  static const LocalizationsDelegate<Translations> delegate = _Delegate();

  static Translations of(BuildContext context) =>
      Localizations.of<Translations>(context, Translations)!;

  static Future<Translations> load(Locale locale) async {
    final String code = locale.languageCode.isEmpty ? 'en' : locale.languageCode;
    return Translations(locale, await _read(code), await _read('en'));
  }

  static Future<Map<String, dynamic>> _read(String code) async {
    try {
      final String raw = await rootBundle.loadString('locale/$code.json');
      return json.decode(raw) as Map<String, dynamic>;
    } on Object {
      // Unsupported locale: let the caller fall back to English.
      return <String, dynamic>{};
    }
  }
}

class _Delegate extends LocalizationsDelegate<Translations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => false;
}
