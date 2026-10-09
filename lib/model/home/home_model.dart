import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../util/constant.dart';
import 'home_layout.dart';

/// Home tab layout source: the bundled config, plus an optional remote override.
class HomeModel {
  HomeModel._();

  static final HomeModel instance = HomeModel._();

  /// Parses the layout shipped in the app bundle.
  Future<HomeLayout> local() async {
    final String raw = await rootBundle.loadString(kLocalLayoutConfig);
    return HomeLayout.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  /// Fetches the layout from [url], accepting either a JSON body or a JSON
  /// string body.
  Future<HomeLayout> remote(String url) async {
    final Response<dynamic> response = await Dio().get<dynamic>(url);
    final dynamic data = response.data;
    final Map<String, dynamic> decoded = data is String
        ? json.decode(data) as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return HomeLayout.fromJson(decoded);
  }
}
