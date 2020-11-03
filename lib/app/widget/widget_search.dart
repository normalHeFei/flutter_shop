import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zdk_app/app/common/Global.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/common/constaints.dart';

///todo 当前选中tab
class CurrTab {
  Map curr;

  static CurrTab _instance;

  factory CurrTab.getInstance() => _getInstance();

  CurrTab._init(this.curr);

  static CurrTab _getInstance() {
    if (_instance == null) {
      _instance = CurrTab._init({
        'name': '淘宝',
        'platform': 'tb',
      });
    }
    return _instance;
  }
}

/// 搜索建议组件 共享数据
class WidgetSearchShareData extends InheritedWidget {
  final List hisSearchKwsPre =
      Global.getStringList(Keys.searchHistory.toString());

  List platformTabs = [
    {
      'name': '淘宝',
      'platform': 'tb',
    },
    {
      'name': '拼多多',
      'platform': 'pdd',
    },
    {
      'name': '京东',
      'platform': 'jd',
    },
  ];

  WidgetSearchShareData({Widget child}) : super(child: child);

  static void addSearchKw(keyword) {
    Global.append(Keys.searchHistory.toString(), keyword);
  }

  static void delSearchKw(keyword) {
    Global.delStringItem(Keys.searchHistory.toString(), keyword);
  }

  @override
  bool updateShouldNotify(WidgetSearchShareData oldWidget) {
    var hisSearchKwsNow = Global.getStringList(Keys.searchHistory.toString());
    return hisSearchKwsNow?.join('') != hisSearchKwsPre?.join('');
  }

  ///这里的context 必须是 InheritedWidget  子 widget 的context
  static WidgetSearchShareData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WidgetSearchShareData>();
  }

  static WidgetSearchShareData getShareData(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<WidgetSearchShareData>()
        .widget;
  }
}

/// 搜索建议组件
class WidgetSearch extends SearchDelegate {
  final String searchHint = "输入商品名称搜索";

  final Function buildRsts;

  var currPlatform;

  WidgetSearch(this.buildRsts);

  @override
  String get searchFieldLabel => searchHint;

  @override
  List<Widget> buildActions(BuildContext context) {
    ///显示在最右边的控件列表
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showResults(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),

      ///调用 close 关闭 search 界面
      onPressed: () => close(context, null),
    );
  }

  ///展示搜索结果
  @override
  Widget buildResults(BuildContext context) {
    return buildRsts(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Suggestions((keyword) {
      query = keyword;
      showResults(context);
    });
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    if (query != null && query.toString().length != 0) {
      Global.append(Keys.searchHistory.toString(), query.trim());
    }
  }
}

class Suggestions extends StatefulWidget {
  final Function onSelected;

  Suggestions(this.onSelected);

  @override
  State<StatefulWidget> createState() {
    return SuggestionsState();
  }
}

class SuggestionsState extends State<Suggestions> {
  final TextStyle searchRecommendTitle = TextStyle(fontWeight: FontWeight.bold);

  List searchRecommends = [];

  @override
  void initState() {
    super.initState();
    Api.getInstance().queryRecommendKeywords().then((recommends) {
      searchRecommends = recommends;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetSearchShareData(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: WidgetPlatformTabs(),
            ),
            Container(
              child: Text('大家都在搜', style: searchRecommendTitle),
            ),
            WidgetSearchItemsView(
              false,
              (kw) {
                widget.onSelected(kw);
              },
              onDel,
              kws: searchRecommends,
            ),
            Container(
              child: Text('搜索记录', style: searchRecommendTitle),
            ),
            WidgetSearchItemsView(true, (kw) {
              widget.onSelected(kw);
            }, onDel),
          ],
        ),
      ),
    );
  }

  /// 更新本地搜索历史.
  void onDel(kw) {
    WidgetSearchShareData.delSearchKw(kw);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

class WidgetPlatformTabs extends StatefulWidget {
  WidgetPlatformTabs();

  @override
  State<StatefulWidget> createState() {
    return WidgetPlatformTabsState();
  }
}

class WidgetPlatformTabsState extends State {
  @override
  Widget build(BuildContext context) {
    var shareData = WidgetSearchShareData.getShareData(context);
    var currTab = CurrTab.getInstance();
    return Flex(
      direction: Axis.horizontal,
      children: shareData.platformTabs
          .map((item) => Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      item['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    decoration: _buildDecoration(item, currTab.curr),
                  ),
                  onTap: () {
                    currTab.curr = item;
                    setState(() {});
                  },
                ),
              ))
          .toList(),
    );
  }

  Decoration _buildDecoration(item, currTab) {
    var boxDecoration =
        BoxDecoration(border: Border(bottom: BorderSide(color: Colors.red)));
    if (item['platform'] == currTab['platform']) {
      return boxDecoration;
    }
    return BoxDecoration();
  }
}

/// 这里一定要用 无状态的 widget 代替 方法创建 widget
class WidgetSearchItemsView extends StatelessWidget {
  final RoundedRectangleBorder shape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  final bool isHis;
  final Function onSelected;
  final Function onDel;
  List kws;

  WidgetSearchItemsView(this.isHis, this.onSelected, this.onDel, {this.kws});

  @override
  Widget build(BuildContext context) {
    if (isHis) {
      kws = WidgetSearchShareData.of(context).hisSearchKwsPre;
    }

    /// 推荐还未返回时. 返回空面板
    if (kws == null || (kws != null && kws.isEmpty)) {
      return Center();
    }
    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          child: Wrap(
            spacing: 10,
            children: kws.map((item) {
              /// 构造Item widget
              return Container(
                child: InkWell(
                  onTap: () {
                    onSelected(item);
                  },

                  /// 历史搜索VIEW, 允许对搜索词进行删除操作
                  child: isHis
                      ? Chip(
                          onDeleted: () {
                            onDel(item);
                          },
                          label: Text(item),
                          shape: shape,
                        )
                      :

                      /// 大家都在搜索VIEW， 不允许对搜索词删除操作
                      Chip(
                          label: Text(item),
                          shape: shape,
                        ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}
