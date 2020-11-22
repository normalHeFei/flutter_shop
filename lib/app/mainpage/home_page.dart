import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/mainpage/search_page.dart';
import 'package:zdk_app/app/widget/widget_fake_search.dart';
import 'package:zdk_app/app/widget/widget_pagelist.dart';
import 'package:zdk_app/app/widget/widget_search.dart';

class HomePage extends StatefulWidget {
  final ScreenUtil screenUtil = ScreenUtil();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with ListItemBuilderMixin {
  Map dynamicParam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: WidgetFakeSearch(() {
            showSearch(
                context: context,
                delegate: WidgetSearch((query) {
                  var curr = CurrTab.getInstance().curr;

                  /// 创建搜索结果页
                  return WidgetPageView(
                    'fromHome',
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
                    listItemBuilder: buildListItem,
                  );
                }));
          }),
        ),
        body: WidgetCustomScrollBody());
  }

  @override
  void initState() {
    super.initState();
    Api.getInstance().queryHomeDynamic().then((value) {
      setState(() {
        dynamicParam = value;
      });
    });
  }
}

class WidgetCustomScrollBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetCustomScrollBodyState();
  }
}

class WidgetCustomScrollBodyState extends State<WidgetCustomScrollBody>
    with ListItemBuilderMixin, AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ///  动态配置内容
        SliverFixedExtentList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              constraints: BoxConstraints.expand(
                  width: ScreenUtil.screenWidth,
                  height: screenUtil.setHeight(200)),

              ///  todo
              child: WidgetDynamic(null),
            );
          }, childCount: 1),
          itemExtent: screenUtil.setHeight(200),
        ),

        /// 晃晃整理
        SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate((BuildContext context, int idx) {
            return WidgetDailyGoods();
          }, childCount: 1),
          itemExtent: screenUtil.setHeight(300),
        ),

        /// 每日推荐
        SliverFillRemaining(
          child: WidgetPageView('fromHome',
              apiMethod: Api.getInstance().pageQueryRecommendGoods,
              listItemBuilder: buildListItem,
              barBuilder: _buildListTitle),
        )
      ],
    );
  }

  PreferredSizeWidget _buildListTitle() {
    return WidgetListTitle();
  }

  @override
  bool get wantKeepAlive => true;
}

class WidgetDailyGoods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
          width: ScreenUtil.screenWidth, height: screenUtil.setHeight(310)),
      child: Wrap(
        direction: Axis.vertical,
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: [
              Icon(
                Icons.favorite_border,
                color: Colors.deepOrange,
              ),
              const Text(
                '晃晃每日推荐',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          ListView.builder(
            itemBuilder: (context, idx) {
              return Container(
                margin: EdgeInsets.all(5),
                constraints: BoxConstraints.expand(
                    width: screenUtil.setWidth(100),
                    height: screenUtil.setHeight(300)),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Image.network(
                        'https://cn.bing.com/th?id=OHR.WoodLine_EN-CN1496881410_800x480.jpg',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "￥10",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: screenUtil.setSp(25),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "￥20",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: screenUtil.setSp(20),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            scrollDirection: Axis.horizontal,
            itemCount: 6,
          )
        ],
      ),
    );
  }
}

class WidgetListTitle extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        Icon(
          Icons.whatshot,
          color: Colors.deepOrange,
        ),
        const Text(
          '猜你喜欢',
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size(ScreenUtil.screenWidth, screenUtil.setHeight(30));
}

class WidgetDynamic extends StatelessWidget {
  final Map param;

  WidgetDynamic(this.param);

  @override
  Widget build(BuildContext context) {
    if (param == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: const Text('动态内容'),
    );
  }
}
