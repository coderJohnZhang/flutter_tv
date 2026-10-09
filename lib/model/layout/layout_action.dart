import '../../util/json_value.dart';

/// What a block does when it is selected.
///
/// A service may describe the target in any of three ways: a logical [action]
/// the host resolves by name, an explicit component ([packageName] together
/// with [activityName]), or a [uri]. [behavior] carries the service's own
/// routing hint. The action is kept verbatim and handed to the host, so the
/// launcher needs no table of target names.
class LayoutAction {
  const LayoutAction({
    this.behavior = '',
    this.action = '',
    this.packageName = '',
    this.activityName = '',
    this.uri = '',
  });

  factory LayoutAction.fromJson(Map<String, dynamic> json) {
    return LayoutAction(
      behavior: Json.text(json['behavior']),
      action: Json.text(json['action']),
      packageName: Json.text(json['package_name']),
      activityName: Json.text(json['activity_name']),
      uri: Json.text(json['uri']),
    );
  }

  final String behavior;
  final String action;
  final String packageName;
  final String activityName;
  final String uri;

  /// True when the payload carries no usable target.
  bool get isEmpty =>
      behavior.isEmpty &&
      action.isEmpty &&
      packageName.isEmpty &&
      activityName.isEmpty &&
      uri.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'behavior': behavior,
        'action': action,
        'package_name': packageName,
        'activity_name': activityName,
        'uri': uri,
      };
}
