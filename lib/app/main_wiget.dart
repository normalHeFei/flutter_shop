import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'mainpage/mine_page.dart';

import 'mainpage/search_page.dart';
import 'mainpage/selfboss_page.dart';

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget>
    with SingleTickerProviderStateMixin {
  List<StatefulWidget> _pages;

  final _bottomNavigationTextColor = Colors.black; // 导航字体颜色
  final _bottomNavigationIconColor = Colors.black; // 导航默认图标颜色
  final _bottomNavigationActiveIconColor = Colors.deepOrange; // 导航选中图标颜色

  int _currentIndex = 0;

  var _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    _pages = [SearchPage(), SelfBossPage(), MinePage()];
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //初始化设计稿长宽,设置参照系
    ScreenUtil.init(context, width: 600, height: 1071);
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: _pages,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _controller.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            activeIcon:
                Icon(Icons.home, color: _bottomNavigationActiveIconColor),
            backgroundColor: Colors.white,
            icon: Icon(Icons.home, color: _bottomNavigationIconColor),
            title:
                Text("首页", style: TextStyle(color: _bottomNavigationTextColor)),
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.shopping_cart,
                color: _bottomNavigationActiveIconColor),
            icon: Icon(Icons.shopping_cart, color: _bottomNavigationIconColor),
            title:
                Text("自营", style: TextStyle(color: _bottomNavigationTextColor)),
          ),
          BottomNavigationBarItem(
            activeIcon:
                Icon(Icons.category, color: _bottomNavigationActiveIconColor),
            icon: Icon(Icons.person_add, color: _bottomNavigationIconColor),
            title:
                Text("我的", style: TextStyle(color: _bottomNavigationTextColor)),
          ),
        ],
      ),
    );
  }
}
