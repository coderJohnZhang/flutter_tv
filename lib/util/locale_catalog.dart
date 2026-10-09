import 'package:flutter/widgets.dart';

/// The languages a TV deployment may be asked to run in.
///
/// A television ships to many markets and the locale list is long. The list is
/// kept here rather than in the widgets so a host can ask what is on offer, and
/// so a language tag can be turned into a `Locale` the framework understands.
///
/// The tags are IETF language tags. The three that need a region or a script to
/// mean anything — simplified and traditional Chinese, and Egyptian Arabic —
/// are mapped explicitly; everything else is a bare language tag.
abstract final class LocaleCatalog {
  /// Every language tag the launcher knows, in the order they are offered.
  static const List<String> languages = <String>[
    'cs', 'da', 'de', 'en', 'es', 'el', 'fr', 'hr', 'it', 'hu',
    'nl', 'nb', 'pl', 'pt', 'ru', 'ro', 'sl', 'sr', 'fi', 'sv',
    'bg', 'sk', 'zh-cn', 'gd', 'cy', 'ar', 'ga', 'lv', 'iw', 'tr',
    'et', 'ko', 'hi', 'mi', 'ab', 'af', 'sq', 'am', 'an', 'hy',
    'as', 'av', 'ae', 'ay', 'az', 'bm', 'ba', 'eu', 'bn', 'bh',
    'bi', 'bs', 'br', 'my', 'ca', 'in', 'ja', 'lt', 'mk', 'ms',
    'mn', 'fa', 'th', 'bo', 'uk', 'uz', 'vi', 'ht', 'ar-eg', 'zh-tw',
  ];

  /// The distinct language codes behind [languages].
  static const List<String> languageCodes = <String>[
    'cs', 'da', 'de', 'en', 'es', 'el', 'fr', 'hr', 'it', 'hu',
    'nl', 'nb', 'pl', 'pt', 'ru', 'ro', 'sl', 'sr', 'fi', 'sv',
    'bg', 'sk', 'zh', 'gd', 'cy', 'ar', 'ga', 'lv', 'iw', 'tr',
    'et', 'ko', 'hi', 'mi', 'ab', 'af', 'sq', 'am', 'an', 'hy',
    'as', 'av', 'ae', 'ay', 'az', 'bm', 'ba', 'eu', 'bn', 'bh',
    'bi', 'bs', 'br', 'my', 'ca', 'in', 'ja', 'lt', 'mk', 'ms',
    'mn', 'fa', 'th', 'bo', 'uk', 'uz', 'vi', 'ht',
  ];

  /// The locales a host may offer, [languages] turned into `Locale` values.
  static List<Locale> get locales =>
      languages.map<Locale>(fromTag).toList(growable: false);

  /// The `Locale` for a language [tag].
  ///
  /// A tag that needs a region or a script to be unambiguous — simplified and
  /// traditional Chinese, Egyptian Arabic — is built with one, so the framework
  /// does not collapse two different markets onto the same locale.
  static Locale fromTag(String tag) {
    switch (tag) {
      case 'zh-cn':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      case 'zh-tw':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      case 'ar-eg':
        return const Locale.fromSubtags(languageCode: 'ar', countryCode: 'EG');
      default:
        return Locale(tag);
    }
  }

  /// Whether [code] is one of the known language codes.
  static bool isKnown(String code) => languageCodes.contains(code);
}
