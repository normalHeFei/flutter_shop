import 'package:flutter/material.dart';
import 'package:zdk_app/app/widget/search_widget.dart';
import '../widget/good_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, this.data}) : super(key: key);
  final String data;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  List<GoodList> _tabs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabs = [
      GoodList(
        '漏洞',
        color: Colors.orange,
      ),
      GoodList('特惠'),
      GoodList('品牌'),
      GoodList('大额券'),
      GoodList('外卖'),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('xxx'),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: SearchBar());
                })
          ],
          bottom: TabBar(tabs: (() {
            List<Widget> tabs = [];
            _tabs.asMap().forEach((idx, value) {
              if (idx == 0) {
                tabs.add(Text(
                  value.text,
                  style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 20),
                ));
                return true;
              }
              tabs.add(Text(value.text));
            });
            return tabs;
          })()),
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
