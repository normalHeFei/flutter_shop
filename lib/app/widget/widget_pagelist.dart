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

  SortObj(this.name, {desc: false, supportSort: false});
}

class WidgetListViewSorter extends StatefulWidget {
  final List<SortObj> sorts;

  const WidgetListViewSorter(this.sorts);

  @override
  State<StatefulWidget> createState() {
    return _WidgetListViewSorterState();
  }
}

class _WidgetListViewSorterState extends State<WidgetListViewSorter> {
  /// 当前点击的排序项
  SortObj currTapSortObj;

  _rebuild() {
    setState(() {});
  }

  @override
  void didUpdateWidget(WidgetListViewSorter oldWidget) {
    super.didUpdateWidget(oldWidget);
    //初始化构建时,发送事件,触发底部列表排序
    currTapSortObj = widget.sorts[0];
    bus.emit('sortChange');
  }

  @override
  Widget build(BuildContext context) {
    List idxList = Iterable<int>.generate(widget.sorts.length).toList();
    return Column(
      children: _buildSortItems(idxList),
    );
  }

  List<Widget> _buildSortItems(List idxList) {
    List<Widget> rst = [];
    for (var idx in idxList) {
      rst.add(Container(
        decoration: BoxDecoration(
            border:
                Border.symmetric(vertical: BorderSide(color: Colors.black26))),
        constraints: BoxConstraints.expand(height: screenUtil.setHeight(30)),
        child: GestureDetector(
            child: Wrap(children: _buildSortItem(idx)),
            onTap: () {
              currTapSortObj = widget.sorts[idx];
              //当前排序项支持排序的话, 则排序方向取反
              if (currTapSortObj.supportSort) {
                currTapSortObj.desc = !currTapSortObj.desc;
              }
              _rebuild();
              //发送事件
              bus.emit('sortChange', currTapSortObj);
            }),
      ));
    }
    return rst;
  }

  List<Widget> _buildSortItem(int idx) {
    List<Widget> sortItem = [Text(widget.sorts[idx].name)];
    if (widget.sorts[idx].supportSort) {
      var sortIcon = (() {
        if (widget.sorts[idx].desc) {
          return Icons.arrow_drop_down;
        } else {
          return Icons.arrow_drop_up;
        }
      })();
      sortItem.add(sortIcon as Widget);
    }
    return sortItem;
  }
}

class WidgetPageView extends StatefulWidget {
  final ListItemBuilder listItemBuilder;

  final OnClick onClick;

  final ApiMethod apiMethod;

  final ApiParamProcess apiParamProcess;

  final WidgetListViewSorter sorter;

  WidgetPageView(
      {this.apiMethod,
      this.apiParamProcess,
      this.listItemBuilder,
      this.onClick,
      this.sorter})
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

    /// 监听排序组件点击事件
    if (widget.sorter != null) {
      bus.on('sortChange', (arg) {
        setState(() {
          currSortObj = arg;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    bus.off('sortChange');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sorter != null) {
      return Stack(
        children: [
          Positioned(top: 0, child: widget.sorter),
          Positioned(
            top: screenUtil.setHeight(30),
            child: _buildList(),
          )
        ],
      );
    }
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
    if (widget.sorter != null) {
      return widget.sorter.sorts[0];
    }
    return null;
  }
}
