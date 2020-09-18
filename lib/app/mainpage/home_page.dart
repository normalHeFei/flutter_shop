import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/widget/widget_banner.dart';
import 'package:zdk_app/app/widget/widget_search.dart';
import 'package:zdk_app/app/widget/widgets_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List _lms;
  TabController _tabController;
  List<Tab> _tabs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    var api = Api.getInstance();
    var value =  api.getLms();
    _init(value);
  }

  _init(value) {
    _lms = value;
    _tabController = TabController(length: _lms.length, vsync: this);
    _tabs = _lms.map((e) => Tab(text: e['self']['name'])).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: SearchBar());
              })
        ],
        bottom: TabBar(
          isScrollable: true,
          indicatorColor: Colors.deepOrangeAccent,
          indicatorWeight: ScreenUtil().setSp(20),
          tabs: _tabs,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _lms.map((e) => _createTabView(e)),
      ),
    );
  }

  _createTabView(Map<String, dynamic> catItem) {
    if (catItem['self']['name'] == '精选') {
      return Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: _createBanner(),
          ),
          Expanded(
            flex: 1,
            child: _createSsrx(),
          ),
          Expanded(
            flex: 2,
            child: _createTuiJian(),
          )
        ],
      );
    } else {
      return _createCommonGoodList();
    }
  }

  _createBanner() async {
    var banners =  await Api.getInstance().getBanners();
    return WidgetBanner(imageUrls: (banners as List ).map((e) => e.image).toList());
  }

  _createPlaceHolder(){
    return Container();
  }

  _createTuiJian() {
    return _createPlaceHolder();
  }

  _createSsrx() {
    return _createPlaceHolder();
  }

  _createCommonGoodList() {
    return _createPlaceHolder();
  }
}
