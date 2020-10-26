import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/Global.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/widget/widget_pagelist.dart';

import 'package:zdk_app/app/widget/widget_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class ValueTab<T> extends Tab {
  final T _value;

  T get value => _value;

  ValueTab(this._value, {String name}) : super(text: name);
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _tabController;
  List<Widget> _tabs;
  List _cats;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cats = Global.get('cats');
    _tabController = TabController(length: _cats.length, vsync: this);
    _tabs = _cats.map((e) {
      return ValueTab(
        e,
        name: e['name'],
      );
    }).toList();
    print('_cats: $_cats');
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
    ApiParamProcess paramProcessor;
    WidgetListViewSorter sorter;

    for (var cat in _cats) {
      paramProcessor = _getSortParamProcess(cat);
      sorter = _getSortWidget(cat);
      rst.add(WidgetPageView(
        sorter: sorter,
        apiParamProcess: paramProcessor,
        apiMethod: Api.getInstance().pageQueryByCat,
        listItemBuilder: _buildListItem,
      ));
    }
    return rst;
  }

  //获取不同平台的排序条
  Widget _getSortWidget(cat) {
    var platform = cat['platform'];
    if (platform == 'pdd') {
      return WidgetListViewSorter([
        SortObj('综合'),
        SortObj('价格'),
        SortObj('销量'),
      ]);
    }
    //淘宝tab 无需排序
    else {
      return null;
    }
  }

  //获取不同平台的排序参数处理函数
  _getSortParamProcess(cat) {
    var platform = cat['platform'];
    if (platform == 'pdd') {
      return (Map<String, dynamic> map) {
        SortObj sortObj = map['sort'] as SortObj;
        if (sortObj != null) {
          map.remove('sort');
          if (sortObj.name == '价格') {
            if (sortObj.desc) {
              map['sort'] = 3;
            } else {
              map['sort'] = 4;
            }
          }
          if (sortObj.name == '销量') {
            if (sortObj.desc) {
              map['sort'] = 5;
            } else {
              map['sort'] = 6;
            }
          }
        }
        if (map['sort'] == null) {
          map['sort'] = 0;
        }
        map['pageNo'] = map['pageNo'] + 1;
        map.addAll({'catId': cat['referId'], 'platform': cat['platform']});
        return map;
      };
    }

    /// 淘宝未找到排序属性, 直接返回原参数
    return (Map<String, dynamic> map) {
      map.addAll({'catId': cat['referId'], 'platform': cat['platform']});
      return map;
    };
  }

  Widget _buildListItem(dynamic itemData) {
    Map item = itemData as Map;
    return Container(
      constraints: BoxConstraints.expand(
          width: screenUtil.setWidth(580), height: screenUtil.setHeight(200)),
      padding: EdgeInsets.fromLTRB(
          screenUtil.setWidth(10),
          screenUtil.setHeight(10),
          screenUtil.setWidth(10),
          screenUtil.setHeight(10)),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 1,
            child: Image.network(item['image']),
          ),
          Expanded(
            flex: 2,
            child: Flex(
              direction: Axis.vertical,
              children: _buildRight(item),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRight(Map item) {
    ScreenUtil screenUtil = ScreenUtil();

    var currPrice = item['currPrice'],
        originalPrice = item['originalPrice'],
        sellNum = item['sellNum'],
        offerContext = item['offerInfo']['context'],
        couponInfo = item['offerInfo']['couponInfo'],
        couponAmt = couponInfo != null ? couponInfo['couponAmt'] : 0,
        offerType = item['offerInfo']['offerType'];

    /// 满减优惠
    if (offerType == 'OFFER_TYPE_MJ') {
      return _buildRightMj(item, offerContext, screenUtil, currPrice, sellNum);

      /// 优惠券
    } else {
      return _buildRightYhq(
          item, screenUtil, currPrice, originalPrice, couponAmt, sellNum);
    }
  }

  List<Widget> _buildRightYhq(Map item, ScreenUtil screenUtil, currPrice,
      originalPrice, couponAmt, sellNum) {
    return [
      Expanded(
        flex: 1,
        child: Text(
          item['goodTitle'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(
        flex: 2,
        child: Stack(
          children: [
            Positioned(
              left: screenUtil.setWidth(5),
              bottom: 0,
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  Text(
                    "￥$currPrice",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: screenUtil.setSp(25),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "￥$originalPrice",
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: screenUtil.setSp(20),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: screenUtil.setWidth(5),
              bottom: 0,
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red, Colors.orange[700]]),
                        borderRadius:
                            BorderRadius.circular(screenUtil.setWidth(3.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                              blurRadius: screenUtil.setWidth(4.0))
                        ]),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenUtil.setWidth(25),
                          vertical: screenUtil.setHeight(5)),
                      child: Text(
                        '$couponAmt元券',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Text(
                    "销量:$sellNum",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenUtil.setSp(20),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildRightMj(
      Map item, offerContext, ScreenUtil screenUtil, currPrice, sellNum) {
    return [
      Expanded(
        flex: 1,
        child: Text(
          item['goodTitle'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          offerContext,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(
          flex: 1,
          child: Stack(
            children: [
              Positioned(
                left: screenUtil.setWidth(5),
                bottom: 0,
                child: Text(
                  "￥$currPrice",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: screenUtil.setSp(25),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: screenUtil.setWidth(5),
                bottom: 0,
                child: Text(
                  "销量:$sellNum",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenUtil.setSp(20),
                  ),
                ),
              )
            ],
          )),
    ];
  }
}
