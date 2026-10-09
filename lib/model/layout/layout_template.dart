import '../../util/json_value.dart';
import 'layout_block.dart';
import 'layout_content.dart';
import 'layout_resource.dart';
import 'layout_tab.dart';

/// The structure payload: which tabs exist and how their blocks sit on the grid.
///
/// The service publishes a template so several devices can share one layout and
/// the structure can be cached independently of the artwork. Timestamps and the
/// signature let a client tell a republished layout from the one it already has.
class LayoutTemplate {
  const LayoutTemplate({
    this.templateId = 0,
    this.templateType = 0,
    this.publishTime = 0,
    this.priority = 0,
    this.startPoint = const <double>[],
    this.order = const <int>[],
    this.tabs = const <LayoutTab>[],
  });

  factory LayoutTemplate.fromJson(Map<String, dynamic> json) {
    return LayoutTemplate(
      templateId: Json.integer(json['template_id']),
      templateType: Json.integer(json['template_type']),
      publishTime: Json.integer(json['publish_time']),
      priority: Json.integer(json['priority']),
      startPoint: Json.decimals(json['start_point']),
      order: Json.integers(json['waterfall_order']),
      tabs: Json.maps(json['tabs']).map<LayoutTab>(LayoutTab.fromJson).toList(growable: false),
    );
  }

  final int templateId;
  final int templateType;
  final int publishTime;
  final int priority;

  /// Origin of the grid, as a fraction of the design canvas.
  final List<double> startPoint;

  /// Tab ids in the order the service wants them presented.
  final List<int> order;

  final List<LayoutTab> tabs;

  /// The tab named [name], or null.
  LayoutTab? tabNamed(String name) {
    for (final LayoutTab tab in tabs) {
      if (tab.name == name) {
        return tab;
      }
    }
    return null;
  }

  /// The tab a launcher starts on: the one flagged active, else the first.
  LayoutTab? get defaultTab {
    for (final LayoutTab tab in tabs) {
      if (tab.active) {
        return tab;
      }
    }
    return tabs.isEmpty ? null : tabs.first;
  }

  /// Pairs every block with the resources the content payload carried for it.
  ///
  /// Blocks are matched by id first so the two payloads stay aligned even when
  /// their order differs, falling back to position. A block whose content is
  /// missing keeps its (empty) resource list rather than dropping off the grid.
  LayoutTemplate merge(LayoutContent? content) {
    if (content == null || content.isEmpty) {
      return this;
    }
    return LayoutTemplate(
      templateId: templateId,
      templateType: templateType,
      publishTime: publishTime,
      priority: priority,
      startPoint: startPoint,
      order: order,
      tabs: <LayoutTab>[
        for (int i = 0; i < tabs.length; i++) tabs[i].withBlocks(_mergeTab(tabs[i], content.tabFor(tabs[i], index: i))),
      ],
    );
  }

  static List<LayoutBlock> _mergeTab(LayoutTab templateTab, LayoutTab? contentTab) {
    if (contentTab == null) {
      return templateTab.blocks;
    }
    return <LayoutBlock>[
      for (int i = 0; i < templateTab.blocks.length; i++)
        templateTab.blocks[i].withResources(
          _resourcesFor(templateTab.blocks[i], contentTab.blocks, i),
        ),
    ];
  }

  static List<LayoutResource> _resourcesFor(
    LayoutBlock templateBlock,
    List<LayoutBlock> contentBlocks,
    int index,
  ) {
    for (final LayoutBlock candidate in contentBlocks) {
      if (templateBlock.blockId != 0 && candidate.blockId == templateBlock.blockId) {
        return candidate.resources;
      }
    }
    if (index < contentBlocks.length) {
      return contentBlocks[index].resources;
    }
    return templateBlock.resources;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'template_id': templateId,
        'template_type': templateType,
        'publish_time': publishTime,
        'priority': priority,
        'start_point': startPoint,
        'waterfall_order': order,
        'tabs': tabs.map((LayoutTab t) => t.toJson()).toList(growable: false),
      };
}
