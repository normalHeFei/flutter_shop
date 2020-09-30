import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/Global.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/common/commons.dart';
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
  List _lms;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _lms = Global.get('lms');
    _tabController = TabController(length: _lms.length, vsync: this);
    _tabs = _lms.map((e) {
      return CatTab(e['self']['name'], e['self']['materialId']);
    }).toList();
    print('_lms: $_lms');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('home page build 调用');
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
        children: _buildTabViews(context),
      ),
    );
  }

  List<Widget> _buildTabViews(BuildContext context) {
    List<Widget> rst = [];
    _lms.asMap().forEach((key, value) {
      if (key == 0) {
        rst.add(_buildFirstTab(value));
      } else {
        rst.add(_buildCommonGoodList(value));
      }
    });
    return rst;
  }

  Widget _buildBanner() {
    return Container(
      constraints: BoxConstraints.tightFor(height: 100),
      child: Image.network(
        'https://img.ivsky.com/img/bizhi/t/201907/28/the_lion_king-001.jpg',
      ),
    );
  }

  _buildPlaceHolder() {
    return Container(
      alignment: Alignment.center,
      child: Text('xxx'),
    );
  }

  _buildListTitle() {
    var screenUtil = ScreenUtil();
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Wrap(
            spacing: screenUtil.setWidth(5),
            children: [
              Icon(
                Icons.bookmark_border,
                color: Colors.red,
              ),
              Text(
                '为你精选好货',
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        )
      ],
    );
  }

  _buildTuiJian() {
    return Container(
      color: Colors.white,
      child: WidgetVerticalMaterialList(
        apiMethod: Api.getInstance().getMaterialList,
        includeTitle: false,
      ),
    );
  }

  _buildCommonGoodList(catItem) {
    return _buildPlaceHolder();
  }

  Widget _buildFirstTab(catItem) {
    var screenUtil = ScreenUtil();
    return Padding(
      padding: EdgeInsets.all(10),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              'https://upfile2.asqql.com/upfile/hdimg/wmtp/wmtp/2015-12/29/4281XaDrZ4Eexn.jpg',
              fit: BoxFit.cover,
              width: ScreenUtil.screenWidth,
              height: screenUtil.setHeight(150),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints.tightFor(
                height: 150, width: ScreenUtil.screenWidth),
            child: ListView.builder(
              itemBuilder: (context, idx) {
                return Text(idx.toString());
              },
              itemCount: 100000,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        _WidgetTestList()
      ]),
    );
  }
}

class _WidgetTestList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetTestListState();
  }
}

class _WidgetTestListState extends State<_WidgetTestList> {
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: 50.0,
      delegate:
          new SliverChildBuilderDelegate((BuildContext context, int index) {
        //创建列表项
        return new Container(
          alignment: Alignment.center,
          color: Colors.lightBlue[100 * (index % 9)],
          child: new Text('list item $index'),
        );
      }, childCount: 50 //50个列表项
              ),
    );
  }
}

class WidgetSsrxGoods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}
