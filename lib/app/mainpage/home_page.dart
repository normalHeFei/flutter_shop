import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/common/utils.dart';
import 'package:zdk_app/app/widget/widget_banner.dart';
import 'package:zdk_app/app/widget/widget_cat_tab.dart';
import 'package:zdk_app/app/widget/widget_ssrx_list.dart';
import 'package:zdk_app/app/widget/widget_search.dart';
import 'package:zdk_app/app/widget/widget_vertical_material_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _tabController;

  List<Widget> _tabs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('home page build 调用');
    var api = Api.getInstance();
    return Utils.createFutureBuilder(api.getLms(), (lms) {
      _tabController = TabController(length: lms.length, vsync: this);
      _tabs = (lms as List).map((e) {
        return CatTab(e['self']['name'], e['self']['materialId']);
      }).toList();

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
            indicatorWeight: ScreenUtil().setSp(5),
            tabs: _tabs,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _createTabViews(lms, context),
        ),
      );
    });
  }

  List<Widget> _createTabViews(lms, BuildContext context) {
    List<Widget> rst = [];
    (lms as List).forEach((element) {
      if (element['self']['name'] == '精选') {
        rst.add(Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 1,
              child: _createBanner(),
            ),
            Expanded(
              flex: 2,
              child: _createSsrx(),
            ),
            Expanded(
              flex: 4,
              child: _createTuiJian(),
            )
          ],
        ));
      } else {
        rst.add(_createCommonGoodList());
      }
    });
    return rst;
  }

  Widget _createBanner() {
    return Utils.createFutureBuilder(Api.getInstance().getBanners(), (data) {
      return WidgetBanner(
        height: ScreenUtil().setHeight(200),
        datas: data,
        onclick: (item) {
          // print('data: $item');
        },
      );
    });
  }

  _createPlaceHolder() {
    return Container(
      alignment: Alignment.center,
      child: Text('xxx'),
    );
  }

  _createSsrx() {
    return WidgetSsrxList();
  }

  _createTuiJian() {
    return WidgetVerticalMaterialList(
      apiMethod: Api.getInstance().getMaterialList,
      includeTitle: false,
    );
  }

  _createCommonGoodList() {
    return _createPlaceHolder();
  }
}
