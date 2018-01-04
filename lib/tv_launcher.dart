import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'page3.dart';
import 'page1.dart';
import 'page2.dart';
import 'page4.dart';
import 'key_code.dart';

/*
 * 页面类
 *  图标
 *  文本
 */
class _Page {
  _Page({
    this.icon,
    this.text,
    this.widget,
  });

  final IconData icon;
  final String text;
  final Widget widget;
}

// 存储所有页面的列表
final List<_Page> _allPages = <_Page>[
  new _Page(icon: Icons.event, text: 'EVENT', widget: new Page1Widget()),
  new _Page(icon: Icons.home, text: 'HOME', widget: new Page2Widget()),
  new _Page(icon: Icons.airplay, text: 'AIRPLAY', widget: new Page3Widget()),
  new _Page(icon: Icons.language, text: 'LANGUAGE', widget: new Page4Widget())
];

class ScrollableTabsDemo extends StatefulWidget {
  @override
  _ScrollableTabsDemoState createState() => new _ScrollableTabsDemoState();
}

// 继承SingleTickerProviderStateMixin，提供单个Ticker（每个动画帧调用它的回调一次）
class _ScrollableTabsDemoState extends State<ScrollableTabsDemo>
    with SingleTickerProviderStateMixin {
  /*
   * 在TabBar和TabBarView之间的坐标选项卡选择
   *  TabBar：质感设计控件，显示水平的一行选项卡
   *  TabBarView：可分布列表，显示与当前所选标签对应的控件
   */
  TabController _controller;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    /*
     * 创建一个对象，用于管理TabBar和TabBarView所需的状态
     *  length：选项卡的总数，存储所有页面的列表中的元素个数
     */
    _controller = new TabController(vsync: this, length: _allPages.length);
    focusNode = new FocusNode();
  }

  // 释放对象使用的资源
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    return new RawKeyboardListener(
        focusNode: focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid rawKeyEventDataAndroid =
                rawKeyDownEvent.data;
            print("keyCode = " + rawKeyEventDataAndroid.keyCode.toString());
            if (rawKeyEventDataAndroid.keyCode == KEY_RIGHT) {
              if (_controller.index == _allPages.length - 1) {
                _controller.index = 0;
              } else {
                _controller.index++;
              }
            } else if (rawKeyEventDataAndroid.keyCode == KEY_LEFT) {
              if (_controller.index == 0) {
                _controller.index = _allPages.length - 1;
              } else {
                _controller.index--;
              }
            }
            _controller.animateTo(_controller.index,
                duration: kTabScrollDuration, curve: Curves.ease);
            print("current index = " + _controller.index.toString());
          }
        },
        child: new Scaffold(
            appBar: new AppBar(
                backgroundColor: Colors.black,
                bottom: new TabBar(
                  indicatorColor: const Color(0x00000000),
                  labelColor: Colors.green,
                  labelStyle: new TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontFamily: 'serif',
                  ),
                  unselectedLabelColor: Colors.white,
                  // 控件的选择和动画状态
                  controller: _controller,
                  // 标签栏是否可以水平滚动
                  isScrollable: true,
                  // 标签控件的列表
                  tabs: _allPages.map((_Page page) {
                    return new Tab(text: page.text, icon: new Icon(page.icon));
                  }).toList(),
                )),
            body: new TabBarView(
              // 控件的选择和动画状态
              controller: _controller,
              // 每个标签一个控件
              children: _allPages.map((_Page page) {
                return new Container(
                    key: new ObjectKey(page.icon), child: page.widget);
              }).toList(),
            )));
  }
}
