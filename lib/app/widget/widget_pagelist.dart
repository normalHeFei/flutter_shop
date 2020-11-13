import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/widget/widget_progress.dart';

typedef OnClick = void Function(State listItemState);
typedef ApiMethod = Future Function(Map<String, dynamic> param);
typedef ListItemBuilder = Widget Function(
    dynamic itemData, BuildContext context);

typedef ApiParamBuilder = Map<String, dynamic> Function(
    SortParam currSortParam, int pageNo);

///列表头
typedef BarBuilder =PreferredSizeWidget Function();

EventBus es = EventBus();
ScreenUtil screenUtil = ScreenUtil();

class SortSelectedEvent {
  SortParam sortParam;

  ///组件引用标识, 避免排序监听多触发
  String identity;

  SortSelectedEvent(this.sortParam, this.identity);
}

class SortParam {
  static Map pddSortMap = {
    '综合': 0,
    '价格': 2,
    '销量': 5,
  };
  static Map tbSortMap = {
    '综合': 'tk_rate',
    '价格': 'price',
    '销量': 'total_sales',
  };

  String name;

  bool desc;

  bool supportSort;

  bool selected;

  SortParam(this.name,
      {this.desc = false, this.supportSort = false, this.selected = false});

  getPlatformSortParam(String platform) {
    if (platform == 'pdd') {
      if (desc ?? false) {
        return {'sort': pddSortMap[name] + 1};
      }
      return {'sort': pddSortMap[name]};
    }
    if (platform == 'tb') {
      if (desc ?? false) {
        return {'tbOrderBy': tbSortMap[name], 'tbAsc': '_des'};
      } else {
        return {'tbOrderBy': tbSortMap[name], 'tbAsc': '_asc'};
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return other is SortParam &&
        name == other.name &&
        desc == other.desc &&
        supportSort == other.supportSort;
  }

  @override
  int get hashCode => name.hashCode + desc.hashCode + supportSort.hashCode;
}

class WidgetPageView extends StatefulWidget {
  final ListItemBuilder listItemBuilder;

  final ApiMethod apiMethod;

  final ApiParamBuilder apiParamBuilder;

  final List<SortParam> initSortParams;

  final String identify;

  final BarBuilder barBuilder;

  WidgetPageView(this.identify, {
    this.apiMethod,
    this.apiParamBuilder,
    this.listItemBuilder,
    this.initSortParams,
    this.barBuilder,
  })
      : assert(listItemBuilder != null),
        assert(apiMethod != null),

  ///排序列表 和 表头不可都有
        assert(initSortParams != null && barBuilder != null)


  @override
  State<StatefulWidget> createState() {
    return _WidgetPageViewState();
  }
}

class _WidgetPageViewState extends State<WidgetPageView> {
  List _items = [];

  int _pageNo = 0;

  SortParam _currSortParam;

  ScrollController _scrollController;

  StreamSubscription _subscription;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    /// 页面初始化自动刷新
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      _getMoreData();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _pageNo++;
        _getMoreData();
      }
    });

    /// 排序监听
    _subscription = es.on<SortSelectedEvent>().listen((event) {
      if (widget.identify != event.identity) {
        return;
      }
      _currSortParam = event.sortParam;
      setState(() {
        _loading = true;
      });
      _handleRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    var bar;
    if (widget.barBuilder != null) {
      bar = widget.barBuilder();
    }
    if (widget.initSortParams != null) {
      bar = _WidgetSortBar(widget.initSortParams, widget.identify);
    }
    return Scaffold(
      appBar: bar,
      body: _loading || _items.isEmpty
          ? WidgetProgress('正在加载')
          : RefreshIndicator(
        child: ListView.builder(
          itemBuilder: (context, idx) {
            return widget.listItemBuilder(_items[idx], context);
          },
          itemCount: _items.length,
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
        ),
        onRefresh: _handleRefresh,
      ),
    );
  }

  Future _handleRefresh() async {
    _items.clear();
    _pageNo = 0;
    return _getMoreData();
  }

  Future _getMoreData() async {
    Map<String, dynamic> param;
    if (widget.apiParamBuilder != null) {
      param = widget.apiParamBuilder(_currSortParam, _pageNo);
    }
    var pageData = await widget.apiMethod(param);
    if (mounted) {
      setState(() {
        _items.addAll((pageData ?? []));
        _loading = false;
      });
    }
  }
}

class _WidgetSortBar extends StatefulWidget implements PreferredSizeWidget {
  final List<SortParam> initData;

  final String identify;

  _WidgetSortBar(this.initData, this.identify);

  @override
  State<StatefulWidget> createState() {
    return _WidgetSortBarState();
  }

  @override
  Size get preferredSize =>
      Size(ScreenUtil.screenWidth, screenUtil.setHeight(50));
}

class _WidgetSortBarState extends State<_WidgetSortBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flex(
        direction: Axis.horizontal,
        children: _buildSortItems(),
      ),
      decoration: BoxDecoration(color: Colors.white),
    );
  }

  List<Widget> _buildSortItems() {
    return widget.initData.map((sortParam) {
      TextStyle selectedStyle;
      Color selectedColor;
      if (sortParam.selected) {
        selectedStyle = TextStyle(color: Colors.deepOrange);
        selectedColor = Colors.deepOrange;
      }
      if (sortParam.supportSort) {
        IconData iconData = sortParam.desc
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_down;
        return Expanded(
            child: GestureDetector(
                child: Align(
                  child: Wrap(
                    children: [
                      Text(
                        sortParam.name,
                        style: selectedStyle,
                      ),
                      Icon(
                        iconData,
                        color: selectedColor,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  sortParam.desc = !sortParam.desc;
                  _doOnTap(sortParam);
                }));
      }
      return Expanded(
        child: GestureDetector(
          child: Align(
              child: Text(
                sortParam.name,
                style: selectedStyle,
              )),
          onTap: () {
            _doOnTap(sortParam);
          },
        ),
      );
    }).toList();
  }

  _doOnTap(SortParam sortParam) {
    ///重新设置选中项, 并发送事件
    widget.initData.forEach((element) {
      element.selected = false;
    });
    sortParam.selected = true;
    es.fire(SortSelectedEvent(sortParam, widget.identify));
  }
}
