import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/mainpage/search_page.dart';
import 'package:zdk_app/app/widget/widget_fake_search.dart';
import 'package:zdk_app/app/widget/widget_pagelist.dart';
import 'package:zdk_app/app/widget/widget_progress.dart';
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
        body: Container(
          /// 50 为搜索框的高度
          constraints: BoxConstraints.expand(width: ScreenUtil.screenWidth),
          child: Flex(direction: Axis.vertical, children: [
            Expanded(
              flex: 1,
              child: WidgetDynamic(dynamicParam),
            ),
            Expanded(
                flex: 2,
                child: WidgetPageView('fromHome',
                    apiMethod: Api.getInstance().pageQueryRecommendGoods,
                    listItemBuilder: buildListItem,
                    barBuilder: _buildListTitle))
          ]),
        ));
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

  PreferredSizeWidget _buildListTitle() {
    return WidgetListTitle();
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
