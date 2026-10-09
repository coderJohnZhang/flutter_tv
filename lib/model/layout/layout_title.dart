import '../../util/json_value.dart';

/// The caption of a tab, a column or a block.
///
/// A layout often carries both a localized caption and a fallback for when no
/// translation exists, which is why the same shape is used for both.
class LayoutTitle {
  const LayoutTitle({
    this.value = '',
    this.visible = true,
    this.displayType = '',
  });

  factory LayoutTitle.fromJson(Map<String, dynamic> json) {
    return LayoutTitle(
      value: Json.text(json['value']),
      // Services differ on the spelling of this flag; accept either.
      visible: Json.integer(
            json['title_visible'] ?? json['title_visiable'],
            1,
          ) !=
          0,
      displayType: Json.text(json['display_type']),
    );
  }

  final String value;
  final bool visible;
  final String displayType;

  /// A caption that renders nothing.
  static const LayoutTitle empty = LayoutTitle();

  /// True when there is a caption to draw.
  bool get isEmpty => !visible || value.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
        'title_visible': visible ? 1 : 0,
        'display_type': displayType,
      };
}
