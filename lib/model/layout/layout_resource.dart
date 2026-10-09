import '../../util/json_value.dart';
import 'layout_action.dart';

/// The artwork and target behind a block.
///
/// A block may carry several resources; the first one supplies what the tile
/// draws. The display and action flags are kept apart because a resource can be
/// shown but not selectable, and the service signals that with `display_control`
/// in the negative.
class LayoutResource {
  const LayoutResource({
    this.resId = 0,
    this.titles = const <String>[],
    this.type = '',
    this.name = '',
    this.imageUrl = '',
    this.displayControl = false,
    this.actionControl = false,
    this.actionType = 0,
    this.resType = 0,
    this.licenseId = '',
    this.action = const LayoutAction(),
    this.defaultAction = const LayoutAction(),
  });

  factory LayoutResource.fromJson(Map<String, dynamic> json) {
    return LayoutResource(
      resId: Json.integer(json['res_id']),
      titles: Json.texts(json['title']),
      type: Json.text(json['type']),
      name: Json.text(json['name']),
      imageUrl: Json.text(json['url']),
      displayControl: Json.flag(json['display_control']),
      actionControl: Json.flag(json['action_control']),
      actionType: Json.integer(json['action_type']),
      resType: Json.integer(json['res_type']),
      licenseId: Json.text(json['licence_id']),
      action: LayoutAction.fromJson(Json.map(json['action_url'])),
      defaultAction: LayoutAction.fromJson(Json.map(json['default_action_url'])),
    );
  }

  final int resId;

  /// Captions, most specific first.
  final List<String> titles;

  final String type;
  final String name;
  final String imageUrl;

  /// Server-side suppression: true hides the resource.
  final bool displayControl;

  /// Server-side suppression: true makes the resource non-selectable.
  final bool actionControl;

  final int actionType;
  final int resType;
  final String licenseId;

  final LayoutAction action;
  final LayoutAction defaultAction;

  /// Best available caption.
  String get title => titles.isEmpty ? name : titles.first;

  /// True when the resource may be drawn.
  bool get isDisplayable => !displayControl;

  /// True when selecting the resource leads somewhere.
  bool get isSelectable => !actionControl && !action.isEmpty;

  /// The target to open, preferring the specific action over the fallback.
  LayoutAction get target => action.isEmpty ? defaultAction : action;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'res_id': resId,
        'title': titles,
        'type': type,
        'name': name,
        'url': imageUrl,
        'display_control': displayControl,
        'action_control': actionControl,
        'action_type': actionType,
        'res_type': resType,
        'licence_id': licenseId,
        'action_url': action.toJson(),
        'default_action_url': defaultAction.toJson(),
      };
}
