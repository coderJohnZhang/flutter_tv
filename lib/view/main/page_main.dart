import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../model/local/remote_input.dart';
import '../../util/constant.dart';
import '../../util/focus_style.dart';
import '../../util/nav_key.dart';
import '../../util/remote_gesture.dart';
import '../../util/screen_util.dart';
import '../../viewmodel/base/view_model.dart';
import '../../viewmodel/main/main_view_model.dart';
import '../focus/focus_block.dart';
import '../focus/spatial_focus_engine.dart';
import '../widget/focus_block_widget.dart';
import '../widget/focus_box_overlay.dart';
import '../widget/launcher_tab_page.dart';
import '../widget/title_widget.dart';
import '../widget/topbar_widget.dart';

/// Launcher shell.
///
/// A single key listener receives every remote event and routes it by the zone
/// that currently holds the focus. Zones hand the focus over explicitly; inside
/// the content zone the target block is chosen geometrically by
/// [SpatialFocusEngine].
class LaunchMainPage extends StatefulWidget {
  const LaunchMainPage({
    super.key,
    required this.child,
    required this.tabCount,
    this.highlightStyle = FocusHighlightStyle.border,
    this.onExit,
  });

  final Widget child;

  /// Number of content tabs, used to keep tab movement in range.
  final int tabCount;

  final FocusHighlightStyle highlightStyle;

  /// Called when the remote asks to go back from the launcher's home position,
  /// where there is nothing left to step out of.
  ///
  /// Left null the press is absorbed. A deployment passes a handler so the host
  /// decides what leaving a launcher means, which is a question only the platform
  /// can answer.
  final VoidCallback? onExit;

  @override
  State<LaunchMainPage> createState() => LaunchMainPageState();
}

class LaunchMainPageState extends State<LaunchMainPage> {
  final List<StatefulElement> _topbarElements = <StatefulElement>[];
  final List<StatefulElement> _titleElements = <StatefulElement>[];
  final List<Element> _pageElements = <Element>[];

  /// Blocks of the active tab. Rebuilt on demand instead of on every key press,
  /// which is what keeps rapid key repeats smooth.
  final List<FocusBlock> _blocks = <FocusBlock>[];
  bool _blocksDirty = true;

  final FocusNode _focusNode = FocusNode(debugLabel: 'launcher-shell');
  final FocusBoxController _focusBox = FocusBoxController();
  final RemoteGestureTranslator _gestures = RemoteGestureTranslator();
  StreamSubscription<RemoteGesture>? _gestureSubscription;

  FocusZone _zone = FocusZone.title;
  int _pageIndex = 0;
  int _topbarIndex = 0;
  FocusBlock? _currentBlock;

  /// The scroll views whose movement the focus box is currently following,
  /// with the listener watching each one.
    final List<(ScrollPosition, VoidCallback)> _followers =
      <(ScrollPosition, VoidCallback)>[];

  bool get _overlayEnabled =>
      widget.highlightStyle != FocusHighlightStyle.border;

  @override
  void initState() {
    super.initState();
    _gestureSubscription = RemoteInput.gestures.listen(_onGesture);
    SchedulerBinding.instance.addPostFrameCallback((_) => _onFirstFrame());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A drag costs the same effort at any resolution, so the travel that counts
    // as one press is taken from the design canvas, not from raw surface pixels.
    _gestures.step = ScreenUtil.of(context).w(kRemoteGestureStep);
  }

  @override
  void dispose() {
    _stopFollowingScroll();
    _gestureSubscription?.cancel();
    _focusNode.dispose();
    _focusBox.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Wiring
  // ---------------------------------------------------------------------------

  void _onFirstFrame() {
    if (!mounted) {
      return;
    }
    _collectElements();
    _titleState(_pageIndex)?.setFocus(true);
  }

  /// Collects the header items, tab titles and tab page elements.
  ///
  /// The [IndexedStack] builds every tab page, so all of them are reachable from
  /// here; only the active one is searched for blocks.
  void _collectElements() {
    _topbarElements.clear();
    _titleElements.clear();
    _pageElements.clear();

    void visitTopbar(Element element) {
      if (element.widget is TopBarWidget) {
        _topbarElements.add(element as StatefulElement);
      }
      element.visitChildren(visitTopbar);
    }

    void visitTitle(Element element) {
      if (element.widget is TitleWidget) {
        _titleElements.add(element as StatefulElement);
      }
      element.visitChildren(visitTitle);
    }

    void visitPage(Element element) {
      if (element.widget is LauncherTabPage) {
        _pageElements.add(element);
      }
      element.visitChildren(visitPage);
    }

    context.visitChildElements(visitTopbar);
    context.visitChildElements(visitTitle);
    context.visitChildElements(visitPage);
    _blocksDirty = true;
  }

  // ---------------------------------------------------------------------------
  // Key entry point
  // ---------------------------------------------------------------------------

  void _handleKey(KeyEvent event) {
    // KeyRepeatEvent is a separate type, so held keys are ignored for free.
    if (event is! KeyDownEvent) {
      return;
    }
    final NavKey? navKey = navKeyFor(event.logicalKey);
    if (navKey != null) {
      _dispatch(navKey);
    }
  }

  /// Turns a drag on the remote's touch surface into the presses it stands for.
  void _onGesture(RemoteGesture gesture) {
    final NavKey? navKey = _gestures.accept(gesture);
    if (navKey != null) {
      _dispatch(navKey);
    }
  }

  /// Routes one action to the zone that currently holds the focus.
  ///
  /// Keys and touch drags both arrive here, so whichever the remote reports the
  /// launcher behaves the same and the zones need to know about neither.
  void _dispatch(NavKey navKey) {
    if (navKey == NavKey.select) {
      _onSelect();
      return;
    }
    if (navKey == NavKey.back) {
      _onBack();
      return;
    }
    switch (_zone) {
      case FocusZone.topbar:
        _handleTopbarKey(navKey);
      case FocusZone.title:
        _handleTitleKey(navKey);
      case FocusZone.content:
        _handleContentKey(navKey);
    }
  }

  /// Activates whatever holds the focus, in whichever zone that is.
  void _onSelect() {
    switch (_zone) {
      case FocusZone.topbar:
        _topbarState(_topbarIndex)?.select();
      case FocusZone.content:
        _ensureBlocks();
        (_currentBlock ?? _focusedBlock())?.select();
      case FocusZone.title:
        break;
    }
  }

  /// Back walks the zones homewards: out of the content, then off the status
  /// bar, then out of the launcher.
  ///
  /// The title row is the home position, so the last step has nowhere left to
  /// go inside the launcher and is offered to the host instead of being absorbed.
  void _onBack() {
    switch (_zone) {
      case FocusZone.content:
        _returnToTitle();
      case FocusZone.topbar:
        _topbarState(_topbarIndex)?.setFocused(false);
        _zone = FocusZone.title;
        _titleState(_pageIndex)?.setFocus(true);
      case FocusZone.title:
        widget.onExit?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Topbar zone
  // ---------------------------------------------------------------------------

  void _handleTopbarKey(NavKey key) {
    if (_topbarElements.isEmpty) {
      return;
    }
    switch (key) {
      case NavKey.left:
        if (_topbarIndex > 0) {
          _topbarState(_topbarIndex)?.setFocused(false);
          _topbarIndex--;
          _topbarState(_topbarIndex)?.setFocused(true);
        }
      case NavKey.right:
        if (_topbarIndex < _topbarElements.length - 1) {
          _topbarState(_topbarIndex)?.setFocused(false);
          _topbarIndex++;
          _topbarState(_topbarIndex)?.setFocused(true);
        }
      case NavKey.down:
        _topbarState(_topbarIndex)?.setFocused(false);
        _zone = FocusZone.title;
        _titleState(_pageIndex)?.setFocus(true);
      case NavKey.up:
      case NavKey.select:
      case NavKey.back:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Title zone
  // ---------------------------------------------------------------------------

  void _handleTitleKey(NavKey key) {
    if (_titleElements.isEmpty) {
      return;
    }
    switch (key) {
      case NavKey.left:
        if (_pageIndex > 0) {
          _refreshTitle();
          _pageIndex--;
          _titleState(_pageIndex)?.setFocus(true);
          _switchPage();
        }
      case NavKey.right:
        if (_pageIndex < widget.tabCount - 1) {
          _refreshTitle();
          _pageIndex++;
          _titleState(_pageIndex)?.setFocus(true);
          _switchPage();
        }
      case NavKey.up:
        // The title keeps its highlight, marking which tab stays active.
        _zone = FocusZone.topbar;
        _titleState(_pageIndex)?.setFocus(true, compact: false);
        _topbarState(_topbarIndex)?.setFocused(true);
      case NavKey.down:
        _zone = FocusZone.content;
        _titleState(_pageIndex)?.setFocus(true, compact: false);
        _focusFirstBlock();
      case NavKey.select:
      case NavKey.back:
        break;
    }
  }

  void _refreshTitle() {
    _titleState(_pageIndex)?.setFocus(false);
  }

  /// Tells the shell to show another tab and invalidates the block list.
  void _switchPage() {
    _stopFollowingScroll();
    _blocksDirty = true;
    _currentBlock = null;
    _focusBox.hide();
    ViewModelProvider.of<MainViewModel>(
      context,
    ).selectPage(_pageIndex, tabCount: widget.tabCount);
  }

  // ---------------------------------------------------------------------------
  // Content zone
  // ---------------------------------------------------------------------------

  void _handleContentKey(NavKey key) {
    _ensureBlocks();
    if (_blocks.isEmpty) {
      // Nothing focusable yet: fall back instead of losing the focus.
      _returnToTitle();
      return;
    }
    for (final FocusBlock block in _blocks) {
      block.calculateRenderRect();
    }

    final FocusBlock? current = _currentBlock ?? _focusedBlock();
    if (current == null) {
      _focusFirstBlock();
      return;
    }

    final FocusBlock? next = SpatialFocusEngine.resolve(current, _blocks, key);
    if (next == null) {
      _handleContentEdge(current, key);
      return;
    }
    _moveFocus(current, next);
    _scrollIntoView(next, key);
  }

  void _moveFocus(FocusBlock from, FocusBlock to) {
    if (!identical(from, to)) {
      from.setFocus(false);
    }
    to.setFocus(true);
    _currentBlock = to;
    _syncFocusBox();
  }

  /// Focus is at the edge of the grid: step out of the zone or change tab.
  void _handleContentEdge(FocusBlock current, NavKey key) {
    switch (key) {
      case NavKey.up:
        _returnToTitle();
      case NavKey.left:
        if (_pageIndex > 0) {
          current.setFocus(false);
          _refreshTitle();
          _pageIndex--;
          _titleState(_pageIndex)?.setFocus(true, compact: false);
          _switchPage();
          _focusFirstBlock();
        }
      case NavKey.right:
        if (_pageIndex < widget.tabCount - 1) {
          current.setFocus(false);
          _refreshTitle();
          _pageIndex++;
          _titleState(_pageIndex)?.setFocus(true, compact: false);
          _switchPage();
          _focusFirstBlock();
        }
      case NavKey.down:
      case NavKey.select:
      case NavKey.back:
        break;
    }
  }

  void _returnToTitle() {
    _stopFollowingScroll();
    _currentBlock?.setFocus(false);
    _currentBlock = null;
    _focusBox.hide();
    _zone = FocusZone.title;
    _titleState(_pageIndex)?.setFocus(true);
  }

  /// Drops the focus on the top-left block and returns the content to the top.
  void _focusFirstBlock() {
    _ensureBlocks();
    final FocusBlock? first = SpatialFocusEngine.firstBlock(_blocks);
    if (first == null) {
      return;
    }
    for (final FocusBlock block in _blocks) {
      block.setFocus(false);
    }
    for (final FocusBlock block in _blocks) {
      block.calculateRenderRect();
    }
    first.setFocus(true);
    _currentBlock = first;
    _syncFocusBox();
    _resetScroll(first);
  }

  // ---------------------------------------------------------------------------
  // Block discovery
  // ---------------------------------------------------------------------------

  /// Rebuilds the block list when needed. Stays dirty while a tab has no blocks
  /// yet so the next key press tries again.
  void _ensureBlocks() {
    if (_blocksDirty) {
      _refreshBlocks();
    }
    if (_blocks.isEmpty) {
      _blocksDirty = true;
    }
  }

  void _refreshBlocks() {
    _blocks.clear();
    if (_pageIndex < _pageElements.length) {
      void visitBlock(Element element) {
        if (element.widget is FocusBlockWidget) {
          // The state class of a FocusBlockWidget implements FocusBlock.
          _blocks.add((element as StatefulElement).state as FocusBlock);
        }
        element.visitChildren(visitBlock);
      }

      _pageElements[_pageIndex].visitChildElements(visitBlock);
    }
    _blocksDirty = false;
    _currentBlock = _focusedBlock();
  }

  FocusBlock? _focusedBlock() {
    for (final FocusBlock block in _blocks) {
      if (block.focused) {
        return block;
      }
    }
    return null;
  }

  void _syncFocusBox() {
    if (!_overlayEnabled) {
      return;
    }
    final FocusBlock? block = _currentBlock;
    if (block == null) {
      _focusBox.hide();
    } else {
      _focusBox.moveTo(block.rect);
    }
  }

  // ---------------------------------------------------------------------------
  // Scrolling
  // ---------------------------------------------------------------------------

  /// Scrolls just enough to bring [block] back inside the visible area.
  ///
  /// The axis follows the key press: sideways moves scroll the row the tile
  /// belongs to, vertical moves scroll the page. Bounds come from the scroll
  /// view's own render box rather than the screen, because the home tab keeps a
  /// banner above the scrolling region.
  void _scrollIntoView(FocusBlock block, NavKey key) {
    final Axis axis;
    switch (key) {
      case NavKey.left:
      case NavKey.right:
        axis = Axis.horizontal;
      case NavKey.up:
      case NavKey.down:
        axis = Axis.vertical;
      case NavKey.select:
      case NavKey.back:
        return;
    }
    final _ScrollTarget? target = _scrollTarget(block, axis);
    if (target == null) {
      return;
    }

    final ScrollPosition position = target.position;
    final Rect viewport = target.viewport;
    final Rect rect = block.rect;
    double offset = position.pixels;

    if (axis == Axis.vertical) {
      if (rect.top < viewport.top) {
        offset -= viewport.top - rect.top + kScrollPadding;
      } else if (rect.bottom > viewport.bottom) {
        offset += rect.bottom - viewport.bottom + kScrollPadding;
      }
    } else {
      if (rect.left < viewport.left) {
        offset -= viewport.left - rect.left + kScrollPadding;
      } else if (rect.right > viewport.right) {
        offset += rect.right - viewport.right + kScrollPadding;
      }
    }

    final double clamped = offset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (clamped == position.pixels) {
      return;
    }
    _followScroll(target.position);
    target.position.animateTo(
      clamped,
      curve: Curves.easeOutCubic,
      duration: kFocusAnimation,
    );
  }

  /// Returns every scroll view [block] sits inside to its starting offset.
  void _resetScroll(FocusBlock block) {
    for (final Axis axis in Axis.values) {
      final _ScrollTarget? target = _scrollTarget(block, axis);
      if (target == null) {
        continue;
      }
      final ScrollPosition position = target.position;
      if (position.pixels != position.minScrollExtent) {
        _followScroll(position);
        position.animateTo(
          position.minScrollExtent,
          curve: Curves.easeOutCubic,
          duration: kFocusAnimation,
        );
      }
    }
  }

  /// Keeps the focus box on the focused block while a scroll carries it along.
  ///
  /// The rectangle a scroll is decided from describes the block only until the
  /// content starts moving, so the box is re-read from the block for as long as
  /// the view underneath it is in motion.
  void _followScroll(ScrollPosition position) {
    if (!_overlayEnabled) {
      return;
    }
    for (final (ScrollPosition, VoidCallback) follower in _followers) {
      if (identical(follower.$1, position)) {
        return;
      }
    }

    void readBlock() {
      final FocusBlock? block = _currentBlock;
      if (block == null) {
        return;
      }
      block.calculateRenderRect();
      _focusBox.snapTo(block.rect);
    }

    _followers.add((position, readBlock));
    position.addListener(readBlock);
  }

  void _stopFollowingScroll() {
    for (final (ScrollPosition position, VoidCallback follower)
        in _followers) {
      position.removeListener(follower);
    }
    _followers.clear();
  }

  /// Finds the closest scroll view of [axis] around [block], together with its
  /// viewport bounds.
  ///
  /// Rows and pages are ordinary scroll views, so the shell never decides where
  /// a block should sit. It walks up from the block to the scroll view that owns
  /// it, which is the question a pointer would ask, and that is what lets the
  /// engine reach a block whatever the layout did with it — including a grid the
  /// launcher did not lay out itself.
  _ScrollTarget? _scrollTarget(FocusBlock block, Axis axis) {
    ScrollPosition? position;
    Rect? viewport;

    block.context.visitAncestorElements((Element element) {
      final Widget widget = element.widget;
      if (widget is Scrollable && _axisOf(widget.axisDirection) == axis) {
        final RenderObject? object = element.renderObject;
        if (object is RenderBox && object.hasSize) {
          if (element is StatefulElement) {
            position = (element.state as ScrollableState).position;
          }
          viewport = object.localToGlobal(Offset.zero) & object.size;
        }
        return false;
      }
      return true;
    });

    final ScrollPosition? found = position;
    final Rect? bounds = viewport;
    if (found == null || bounds == null) {
      return null;
    }
    return _ScrollTarget(found, bounds);
  }

  static Axis _axisOf(AxisDirection direction) {
    return direction == AxisDirection.left || direction == AxisDirection.right
        ? Axis.horizontal
        : Axis.vertical;
  }

  // ---------------------------------------------------------------------------
  // Element accessors
  // ---------------------------------------------------------------------------

  TopBarWidgetState? _topbarState(int index) =>
      index >= 0 && index < _topbarElements.length
      ? _topbarElements[index].state as TopBarWidgetState
      : null;

  TitleWidgetState? _titleState(int index) =>
      index >= 0 && index < _titleElements.length
      ? _titleElements[index].state as TitleWidgetState
      : null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: widget.child,
        ),
        if (_overlayEnabled) FocusBoxOverlay(controller: _focusBox),
      ],
    );
  }
}

/// A scroll view a block lives in, together with the bounds it clips against.
class _ScrollTarget {
  const _ScrollTarget(this.position, this.viewport);

  final ScrollPosition position;
  final Rect viewport;
}
