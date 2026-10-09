import 'dart:convert';

import 'package:dio/dio.dart';

import '../../util/constant.dart';
import '../../util/json_value.dart';
import 'layout_column.dart';
import 'layout_content.dart';
import 'layout_template.dart';
import 'page_result.dart';

/// The network seam under [LayoutSource].
///
/// Keeping the HTTP call behind an interface lets the paging and parsing logic
/// be exercised without a server, and keeps the source itself free of any
/// dependency on how the request is made.
abstract class LayoutTransport {
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query});
}

/// Requests the layout over HTTP with `dio`.
class HttpLayoutTransport implements LayoutTransport {
  HttpLayoutTransport({required String baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 5),
                responseType: ResponseType.plain,
              ),
            );

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      path,
      queryParameters: query,
    );
    final dynamic body = response.data;
    if (body is Map) {
      return body.cast<String, dynamic>();
    }
    // The service answers with a JSON document as text rather than as an
    // object, so the body is decoded here instead of by dio.
    final String text = body?.toString() ?? '';
    final dynamic decoded = text.isEmpty ? null : _tryDecode(text);
    return decoded is Map ? decoded.cast<String, dynamic>() : const <String, dynamic>{};
  }

  void dispose() => _dio.close(force: true);

  static dynamic _tryDecode(String text) {
    try {
      return json.decode(text);
    } on FormatException {
      return null;
    }
  }
}

/// Reads the server-driven layout: the template, its content and its columns.
///
/// Every call reports failure as null (or an empty page) rather than throwing,
/// so the caller can fall back to a bundled layout without guarding each call.
abstract class LayoutSource {
  /// The layout structure, or null when it cannot be read.
  Future<LayoutTemplate?> template();

  /// The artwork for [templateId], or null when it cannot be read.
  Future<LayoutContent?> content(int templateId);

  /// One page of columns for a tab, or null when the page cannot be read.
  ///
  /// An empty page and an unreadable page are different answers: the first ends
  /// the list, the second should leave the caller free to ask again.
  Future<PageResult<LayoutColumn>?> columns({
    required int templateId,
    required int tabId,
    required String tabName,
    required int pageNo,
  });

  /// Asks the service to assign this launcher an identifier, or null when the
  /// service does not issue one.
  ///
  /// A launcher the service has never seen has no identifier, and the service is
  /// the one that issues it: the device enrols once, keeps what it was given, and
  /// sends it with every later request. An implementation for a deployment that
  /// identifies devices another way simply returns null, and the caller carries
  /// on without one.
  Future<String?> enrol();
}

/// A [LayoutSource] backed by a layout service.
class RemoteLayoutSource implements LayoutSource {
  RemoteLayoutSource({
    LayoutTransport? transport,
    String baseUrl = kRemoteLayoutBaseUrl,
    this.pageSize = kColumnPageSize,
    this.appVersion = '',
    this.successCode = defaultSuccessCode,
    Map<String, String> context = const <String, String>{},
  })  : _transport = transport ?? HttpLayoutTransport(baseUrl: baseUrl),
        context = Map<String, String>.of(context);

  /// The error code the service returns on a successful call.
  static const int defaultSuccessCode = 1000;

  final LayoutTransport _transport;

  /// How many columns to ask for per page.
  final int pageSize;

  /// Build of the launcher, sent so a service can target a version.
  final String appVersion;

  /// What the device is, sent with every request.
  ///
  /// A layout service sizes and filters by the device it is answering, so the
  /// request carries the model, the locale, the region and the identities the
  /// host reported. Nothing here is baked in: an empty context is valid and
  /// simply means the service gets no context.
  ///
  /// Mutable because enrolment adds to it: the identifier the service issues is
  /// part of what a later request must carry.
  final Map<String, String> context;

  final int successCode;

  /// True when a base URL is configured, i.e. the service is usable.
  static bool get isConfigured => kRemoteLayoutBaseUrl.isNotEmpty;

  @override
  Future<LayoutTemplate?> template() async {
    final Map<String, dynamic> body = await _get(kLayoutTemplatePath);
    return _guard(body, () => LayoutTemplate.fromJson(_payload(body)));
  }

  @override
  Future<LayoutContent?> content(int templateId) async {
    final Map<String, dynamic> body = await _get(
      kLayoutContentPath,
      <String, dynamic>{'template_id': templateId},
    );
    return _guard(body, () => LayoutContent.fromJson(_payload(body)));
  }

  @override
  Future<PageResult<LayoutColumn>?> columns({
    required int templateId,
    required int tabId,
    required String tabName,
    required int pageNo,
  }) async {
    final Map<String, dynamic> body = await _get(
      kLayoutColumnPath,
      <String, dynamic>{
        'template_id': templateId,
        'tab_id': tabId,
        'tab_name': tabName,
        'page_no': pageNo,
        'page_size': pageSize,
      },
    );
    if (!_isSuccess(body)) {
      return null;
    }
    return PageResult.fromJson(
      _payload(body),
      itemsKey: 'columns',
      item: LayoutColumn.fromJson,
      pageNo: pageNo,
      pageSize: pageSize,
    );
  }

  @override
  Future<String?> enrol() async {
    final Map<String, dynamic> body = await _get(kLayoutEnrolPath);
    if (!_isSuccess(body)) {
      return null;
    }
    final String assigned = Json.text(_payload(body)['launcher_id']);
    if (assigned.isEmpty) {
      return null;
    }
    // Later requests have to carry what was issued, so the context is updated
    // here rather than by the caller.
    context['launcher_id'] = assigned;
    return assigned;
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, dynamic>? extra,
  ]) async {
    try {
      return await _transport.get(
        path,
        query: <String, dynamic>{
          'resolution': '${kDesignWidth.toInt()}*${kDesignHeight.toInt()}',
          'param': DateTime.now().millisecondsSinceEpoch,
          if (appVersion.isNotEmpty) 'app_version': appVersion,
          ...context,
          ...?extra,
        },
      );
    } on Object {
      // Unreachable or malformed: the caller falls back to the bundled layout.
      return const <String, dynamic>{};
    }
  }

  /// Unwraps the envelope around the payload.
  Map<String, dynamic> _payload(Map<String, dynamic> body) {
    final dynamic data = body['data'];
    return data is Map ? data.cast<String, dynamic>() : body;
  }

  bool _isSuccess(Map<String, dynamic> body) {
    final dynamic code = body['error_code'];
    if (code == null) {
      return body.isNotEmpty;
    }
    final int value = code is num ? code.toInt() : int.tryParse(code.toString()) ?? -1;
    return value == successCode || value == 0;
  }

  T? _guard<T>(Map<String, dynamic> body, T Function() parse) {
    if (!_isSuccess(body)) {
      return null;
    }
    try {
      return parse();
    } on Object {
      return null;
    }
  }
}
