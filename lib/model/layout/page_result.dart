/// One page of a paginated list.
///
/// Content that grows without bound is fetched a page at a time. The service
/// reports the total size, so a client can tell the last page apart from a page
/// that merely happens to be short — which matters because asking for a page
/// past the end is the only reliable end-of-list signal otherwise.
class PageResult<T> {
  const PageResult({
    required this.pageNo,
    required this.pageSize,
    required this.totalSize,
    required this.items,
  });

  factory PageResult.fromJson(
    Map<String, dynamic> json, {
    required String itemsKey,
    required T Function(Map<String, dynamic>) item,
    int pageNo = 1,
    int pageSize = 0,
  }) {
    final List<dynamic> raw = json[itemsKey] is List
        ? json[itemsKey] as List<dynamic>
        : const <dynamic>[];
    return PageResult<T>(
      pageNo: pageNo,
      pageSize: pageSize,
      totalSize: _asInt(json['total_size']),
      items: <T>[
        for (final dynamic entry in raw)
          if (entry is Map) item(entry.cast<String, dynamic>()),
      ],
    );
  }

  /// An end-of-list page, used when nothing more can be fetched.
  static PageResult<E> empty<E>({int pageNo = 1, int pageSize = 0}) =>
      PageResult<E>(
        pageNo: pageNo,
        pageSize: pageSize,
        totalSize: 0,
        items: const <Never>[],
      );

  /// One-based index of this page.
  final int pageNo;

  /// Number of items requested per page.
  final int pageSize;

  /// Total items the service holds. Zero or less means it did not say.
  final int totalSize;

  final List<T> items;

  bool get isEmpty => items.isEmpty;

  /// The page to request next.
  int get nextPageNo => pageNo + 1;

  /// True when another page is worth requesting.
  ///
  /// A reported total settles it. Without one this can only fall back on the
  /// page being full, which keeps the caller from stopping early while still
  /// terminating once a short page arrives.
  bool get hasMore {
    if (items.isEmpty) {
      return false;
    }
    if (totalSize > 0) {
      return pageNo * pageSize < totalSize;
    }
    return pageSize <= 0 || items.length >= pageSize;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
