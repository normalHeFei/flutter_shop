import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/events.dart';

typedef OnClick = void Function(State listItemState);
typedef ApiMethod = Future Function(Map<String, dynamic> param);
typedef ListItemBuilder = Widget Function(dynamic itemData);
typedef ApiParamProcess = Map<String, dynamic> Function(
    Map<String, dynamic> param);

ScreenUtil screenUtil = ScreenUtil();

class SortObj {
  String name;

  bool desc;

  bool supportSort;

  SortObj(this.name, {this.desc = false, this.supportSort = false});
}

class WidgetPageView extends StatefulWidget {
  final ListItemBuilder listItemBuilder;

  final OnClick onClick;

  final ApiMethod apiMethod;

  final ApiParamProcess apiParamProcess;

  WidgetPageView(
      {this.apiMethod,
      this.apiParamProcess,
      this.listItemBuilder,
      this.onClick})
      : assert(listItemBuilder != null),
        assert(apiMethod != null);

  @override
  State<StatefulWidget> createState() {
    return _WidgetPageViewState();
  }
}

class _WidgetPageViewState extends State<WidgetPageView> {
  List _items = [];

  int _pageNo = 0;

  SortObj currSortObj;

  ScrollController _scrollController;

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
  }

  @override
  void dispose() {
    super.dispose();
    bus.off('sortChange');
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: (context, idx) {
          return widget.listItemBuilder(_items[idx]);
        },
        itemCount: _items.length,
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
      ),
      onRefresh: _handleRefresh,
    );
  }

  Future _handleRefresh() async {
    _items.clear();
    _pageNo = 0;
    return _getMoreData();
  }

  Future _getMoreData() async {
    Map<String, dynamic> sortParam = {
      'pageNo': _pageNo,
      'pageSize': 10,
      'sort': _getCurrSortObj()
    };
    var pageData = await widget.apiMethod(widget.apiParamProcess(sortParam));
    if (mounted) {
      setState(() {
        _items.addAll((pageData as List));
      });
    }
  }

  _getCurrSortObj() {
    if (currSortObj != null) {
      return currSortObj;
    }
    return null;
  }
}
