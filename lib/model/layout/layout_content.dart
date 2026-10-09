import '../../util/json_value.dart';
import 'layout_tab.dart';

/// The artwork payload: which resources sit on each block of a template.
///
/// A layout and its content arrive separately so the structure can be cached
/// while the artwork changes. This model is the content half; [LayoutTemplate]
/// is the structure half, and the two are paired by [LayoutTemplate.merge].
class LayoutContent {
  const LayoutContent({
    this.templateId = 0,
    this.publishTime = 0,
    this.i18nUrl = '',
    this.tabs = const <LayoutTab>[],
  });

  factory LayoutContent.fromJson(Map<String, dynamic> json) {
    return LayoutContent(
      templateId: Json.integer(json['template_id']),
      publishTime: Json.integer(json['publish_time']),
      i18nUrl: Json.text(json['i18n_url']),
      tabs: Json.maps(json['tabs']).map<LayoutTab>(LayoutTab.fromJson).toList(growable: false),
    );
  }

  final int templateId;
  final int publishTime;

  /// Where the service hosts the captions for this template.
  final String i18nUrl;

  final List<LayoutTab> tabs;

  /// The content tab matching [templateTab], by id when the service sends one.
  ///
  /// Pairing by id keeps the two payloads aligned even when one of them lists
  /// the tabs in a different order; the position is only a fallback.
  LayoutTab? tabFor(LayoutTab templateTab, {required int index}) {
    for (final LayoutTab tab in tabs) {
      if (templateTab.tabId != 0 && tab.tabId == templateTab.tabId) {
        return tab;
      }
    }
    if (index >= 0 && index < tabs.length) {
      return tabs[index];
    }
    return null;
  }

  bool get isEmpty => tabs.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'template_id': templateId,
        'publish_time': publishTime,
        'i18n_url': i18nUrl,
        'tabs': tabs.map((LayoutTab t) => t.toJson()).toList(growable: false),
      };
}
