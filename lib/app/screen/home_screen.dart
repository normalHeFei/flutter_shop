import 'package:flutter/material.dart';
import '../widget//good_lists.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, this.data}) : super(key: key); //构造函数中增加参数
  final String data; //为参数分配空间
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class GoodsTab {
  //商品列表 tab包装 类
  String text;
  GoodList goodList;

  GoodsTab(this.text, this.goodList);
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持底部切换状态不变

  Widget _widget_barSearch() {
    return new Container(
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new FlatButton.icon(
              onPressed: () {
                // 点击事件
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return new SearchScreen();
                }));
              },
              icon: new Icon(Icons.search, size: 18.0),
              label: new Text("默认搜索文字"),
            )),
          ],
        ),
        decoration: new BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
        ));
  }

  final List<GoodsTab> myTabs = <GoodsTab>[
    new GoodsTab('淘宝', new GoodList(listType: 'tb')),
    new GoodsTab('拼多多', new GoodList(listType: 'pdd')),
    new GoodsTab('京东', new GoodList(listType: 'jd')),
    new GoodsTab('美团', new GoodList(listType: 'mt')),
    new GoodsTab('饿了么', new GoodList(listType: 'elm'))
  ];

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
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: new AppBar(
          elevation: 0,
          title: _widget_barSearch(),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    forceElevated: innerBoxIsScrolled,
                    title: TabBar(
                      isScrollable: true,
                      tabs: myTabs.map((GoodsTab item) {
                        return new Tab(text: item.text);
                      }).toList(),
                    ),
                  )),
            ];
          },
          body: TabBarView(
            children: myTabs.map((item) {
              return item.goodList;
            }).toList(),
          ),
        ),
      ),
    );
  }
}
