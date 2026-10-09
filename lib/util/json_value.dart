/// Tolerant readers for a decoded JSON payload.
///
/// A layout service is not uniform about types: a dimension may arrive as a
/// number or as a string, a list may be missing, and a flag may be omitted.
/// These readers apply a fallback instead of throwing, so a single unexpected
/// field degrades one value rather than discarding the whole response.
abstract final class Json {
  static String text(dynamic value, [String fallback = '']) {
    if (value == null) {
      return fallback;
    }
    return value is String ? value : value.toString();
  }

  static int integer(dynamic value, [int fallback = 0]) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static double decimal(dynamic value, [double fallback = 0.0]) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool flag(dynamic value, [bool fallback = false]) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry<String, dynamic>(key.toString(), item),
      );
    }
    return const <String, dynamic>{};
  }

  static List<dynamic> list(dynamic value) =>
      value is List ? value : const <dynamic>[];

  static List<String> texts(dynamic value) =>
      list(value).map<String>((dynamic item) => text(item)).toList(growable: false);

  static List<int> integers(dynamic value) =>
      list(value).map<int>((dynamic item) => integer(item)).toList(growable: false);

  static List<double> decimals(dynamic value) =>
      list(value).map<double>((dynamic item) => decimal(item)).toList(growable: false);

  static List<Map<String, dynamic>> maps(dynamic value) =>
      list(value).map<Map<String, dynamic>>(map).toList(growable: false);
}
