import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zdk_app/app/common/Global.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/widget/widget_fake_search.dart';
import 'package:zdk_app/app/widget/widget_pagelist.dart';
import 'package:zdk_app/app/widget/widget_progress.dart';

import 'package:zdk_app/app/widget/widget_search.dart';

EventBus eventBus = EventBus();

class CatSelectedEvent {
  Map curr;

  CatSelectedEvent(this.curr);
}

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
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        ListItemBuilderMixin {
  TabController _tabController;
  List<Widget> _tabs;
  List _cats;
  StreamSubscription _subscription;

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

    ///初始化监听器
    _subscription = eventBus.on<CatSelectedEvent>().listen((event) {
      var idx = _cats.asMap().entries.firstWhere((element) {
        return element.value['id'] == event.curr['id'];
      })?.key;
      if (idx != -1) {
        Navigator.pop(context);
        _tabController.animateTo(idx);
      }
    });
    print('_cats: $_cats');
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: WidgetFakeSearch(() {
          /// 取消 tab 列表页的 排序订阅, 不然搜索页点击排序,会触发外面的监听

          showSearch(
              context: context,
              delegate: WidgetSearch((query) {
                var curr = CurrTab.getInstance().curr;

                /// 创建搜索结果页
                return WidgetPageView(
                  'fromSearch',
                  initSortParams: [
                    SortParam('综合'),
                    SortParam('销量', supportSort: true, desc: true),
                    SortParam('价格', supportSort: true, desc: false),
                  ],
                  apiMethod: Api.getInstance().pageQueryByKw,
                  apiParamBuilder: (sortParam, pageNo) {
                    if (sortParam == null) {
                      sortParam = SortParam('综合');
                    }
                    var platform = curr['platform'],
                        param = {
                          'platform': platform,
                          'pageNo': platform == 'pdd' ? ++pageNo : pageNo,
                          'keyword': query
                        };
                    param.addAll(sortParam.getPlatformSortParam(platform));
                    return param;
                  },
                  listItemBuilder: _buildListItem,
                );
              }));
        }),
        actions: [_WidgetCatMoreBtn()],
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
    for (var cat in _cats) {
      var platform = cat['platform'];
      List<SortParam> initSortParams;
      if (platform == 'pdd') {
        initSortParams = [
          SortParam('综合'),
          SortParam('销量', supportSort: true, desc: true),
          SortParam('价格', supportSort: true, desc: false),
        ];
      }
      rst.add(WidgetPageView(
        'fromTab',
        initSortParams: initSortParams,
        apiParamBuilder: (sortParam, pageNo) {
          var param = {
            'catId': cat['referId'],
            'platform': platform,
            'pageNo': platform == 'pdd' ? ++pageNo : pageNo
          };

          ///不支持排序
          if (sortParam == null) {
            return param;
          } else {
            param.addAll(sortParam.getPlatformSortParam(platform));
            return param;
          }
        },
        apiMethod: Api.getInstance().pageQueryByCat,
        listItemBuilder: _buildListItem,
      ));
    }
    return rst;
  }

  _getKwProcessFun(Map currPlatform, String keyword) {
    return (Map<String, dynamic> rawParam) {
      rawParam['keyword'] = keyword;
      rawParam['platform'] = currPlatform['platform'];
      rawParam['pageNo'] = ++rawParam['pageNo'];
      return rawParam;
    };
  }
}

class WidgetTbDialog extends StatefulWidget {
  final Future queryPwdFuture;

  WidgetTbDialog(this.queryPwdFuture);

  @override
  State<StatefulWidget> createState() {
    return WidgetTbDialogState();
  }
}

class WidgetTbDialogState extends State<WidgetTbDialog> {
  String qwdState;

  @override
  Widget build(BuildContext context) {
    if (qwdState == null) {
      return Center(
        child: const CircularProgressIndicator(),
      );
    }
    return AlertDialog(
      content: Text(qwdState),
      actions: [
        FlatButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text('复制'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: qwdState));
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.queryPwdFuture.then((qwd) {
      setState(() {
        qwdState = qwd;
      });
    });
  }
}

mixin ListItemBuilderMixin {
  Widget _buildListItem(dynamic itemData, BuildContext context) {
    Map item = itemData as Map;
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints.tightFor(
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
      ),
      onTap: () {
        _gotoThirdApp(item, context);
      },
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

  /// 跳转到第三方app
  _gotoThirdApp(Map<dynamic, dynamic> item, BuildContext context) {
    print('点击了, item:  $item');
    // 暂且通过show dialog 的方式显示进度条
    var platform = item['platform'], tbShareUrl = item['tbShareUrl'];
    if (platform == 'pdd') {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return WidgetProgress('前往拼多多');
          });
      Api.getInstance()
          .queryPddSchemaUrl({'itemId': item['itemId']}).then((urls) {
        canLaunch(urls['schemaUrl']).then((can) {
          if (can) {
            launch(urls['schemaUrl'])
                .then((value) => Navigator.of(context).pop());
          } else {
            launch(urls['wxUrl']).then((value) => Navigator.of(context).pop());
          }
        });
      });
    }
    // tb 打开淘口令 对话框
    if (platform == 'tb') {
      showDialog(
          context: context,
          builder: (ctx) {
            return WidgetTbDialog(
                Api.getInstance().queryTbPwd({'url': tbShareUrl}));
          });
    }
  }
}

class _WidgetCatMoreBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: Container(
          child: const Text(
            '☰分类',
            style: TextStyle(color: Colors.red),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.red.shade50),
          margin: EdgeInsets.only(right: screenUtil.setWidth(10)),
          padding: EdgeInsets.symmetric(vertical: screenUtil.setHeight(10)),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return WidgetCatMoreRoute();
          }));
        },
      ),
    );
  }
}

class WidgetCatMoreRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetCatMoreRouteState();
  }
}

class WidgetCatMoreRouteState extends State {
  static final Map platformMap = {'淘宝': 'tb', '拼多多': 'pdd', '京东': 'jd'};
  String currTabText;

  final TextStyle selectedStyle = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热门分类'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(width: ScreenUtil.screenWidth),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                flex: 1,
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    _buildTab('淘宝'),
                    Divider(
                      color: Colors.grey.shade900,
                      height: screenUtil.setHeight(1),
                    ),
                    _buildTab('拼多多'),
                    Divider(
                      color: Colors.grey.shade900,
                      height: screenUtil.setHeight(1),
                    ),
                    _buildTab('京东'),
                  ],
                )),
            Expanded(flex: 5, child: _buildTabView())
          ],
        ),
      ),
    );
  }

  Widget _buildTabView() {
    List cats = Global.get('cats') as List;
    var currPlatformCats = cats.where((element) {
      return element['platform'] == platformMap[currTabText];
    }).map((e) {
      return WidgetCatMoreItem(e);
    }).toList();
    return Scrollbar(
      child: SingleChildScrollView(
        child: Wrap(
          spacing: screenUtil.setWidth(10),
          runSpacing: screenUtil.setHeight(8),
          children: currPlatformCats,
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    BoxDecoration decoration;
    TextStyle textStyle;
    if (currTabText == text) {
      textStyle = selectedStyle;
    }
    return GestureDetector(
      child: Container(
        height: screenUtil.setHeight(100),
        decoration: decoration,
        child: Text(
          text,
          style: textStyle,
        ),
      ),
      onTap: () {
        setState(() {
          currTabText = text;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    ///默认选择
    currTabText = '淘宝';
  }
}

class WidgetCatMoreItem extends StatelessWidget {
  final Map cat;

  WidgetCatMoreItem(this.cat);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Text(cat['name']),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.deepOrangeAccent.shade100),
      ),
      onTap: () {
        eventBus.fire(CatSelectedEvent(cat));
      },
    );
  }
}
