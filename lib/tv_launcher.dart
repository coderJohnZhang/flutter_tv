import 'package:flutter/material.dart';
import 'page2.dart';
import 'page0.dart';
import 'page1.dart';
import 'page3.dart';
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

class PosterDemo extends StatefulWidget {
  @override
  _PosterDemoState createState() => new _PosterDemoState();
}

// 继承SingleTickerProviderStateMixin，提供单个Ticker（每个动画帧调用它的回调一次）
class _PosterDemoState extends State<PosterDemo>
    with SingleTickerProviderStateMixin {
  /*
   * 在TabBar和TabBarView之间的坐标选项卡选择
   *  TabBar：质感设计控件，显示水平的一行选项卡
   *  TabBarView：可分布列表，显示与当前所选标签对应的控件
   */
  TabController _controller;
  List<_Page> _allPages;

  @override
  void initState() {
    super.initState();
    _allPages = <_Page>[
      new _Page(
          icon: Icons.event,
          text: 'EVENT',
          widget: new Page0Widget(
            turnPage: (int key) {
              turnPage(key);
            },
          )),
      new _Page(
          icon: Icons.home,
          text: 'HOME',
          widget: new Page1Widget(
            turnPage: (int key) {
              turnPage(key);
            },
          )),
      new _Page(
          icon: Icons.airplay,
          text: 'AIRPLAY',
          widget: new Page2Widget(
            turnPage: (int key) {
              turnPage(key);
            },
          )),
      new _Page(
          icon: Icons.language,
          text: 'LANGUAGE',
          widget: new Page3Widget(
            turnPage: (int key) {
              turnPage(key);
            },
          ))
    ];
    /*
     * 创建一个对象，用于管理TabBar和TabBarView所需的状态
     *  length：选项卡的总数，存储所有页面的列表中的元素个数
     */
    _controller = new TabController(vsync: this, length: _allPages.length);
  }

  void turnPage(int key) {
    if (key == KEY_LEFT) {
      if (_controller.index == 0) {
        _controller.index = _allPages.length - 1;
      } else {
        _controller.index--;
      }
    } else if (key == KEY_RIGHT) {
      if (_controller.index == _allPages.length - 1) {
        _controller.index = 0;
      } else {
        _controller.index++;
      }
    }
    _controller.animateTo(_controller.index,
        duration: kTabScrollDuration, curve: Curves.ease);
    print("current index = " + _controller.index.toString());
  }

  // 释放对象使用的资源
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
        ));
  }
}
