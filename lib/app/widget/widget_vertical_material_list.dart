import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidgetVerticalMaterialList extends StatefulWidget {
  String _title;
  String _materialId;
  Function _apiMethod;
  Widget _listTitle;
  bool _includeTitle;

  WidgetVerticalMaterialList(
      {Function apiMethod,
      String title,
      Widget listTitle,
      String materialId,
      bool includeTitle = true}) {
    this._apiMethod = apiMethod;
    this._title = title;
    this._materialId = materialId;
    this._includeTitle = includeTitle;
    this._listTitle = listTitle;
  }

  @override
  _WidgetVerticalMaterialListState createState() =>
      _WidgetVerticalMaterialListState();
}

class _WidgetVerticalMaterialListState
    extends State<WidgetVerticalMaterialList> {
  List _items = [];
  int _pageNo = 0;
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
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenUtil = ScreenUtil();
    if (widget._includeTitle) {
      return Scaffold(
        appBar: AppBar(
          title: _buildText(),
        ),
        body: RefreshIndicator(
          child: _buildList(screenUtil),
          onRefresh: _handleRefresh,
        ),
      );
    }
    return RefreshIndicator(
      child: _buildList(screenUtil),
      onRefresh: _handleRefresh,
    );
  }

  Future<Void> _getMoreData() async {
    Map<String, dynamic> param = {
      'pageNo': _pageNo,
      'materialId': widget._materialId
    };
    var pageData = await widget._apiMethod(param);
    if (mounted) {
      setState(() {
        _items.addAll((pageData as List));
      });
    }
  }

  Widget _buildText() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        widget._title,
        style: TextStyle(
            color: Colors.orange,
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }


  ListView _buildList(ScreenUtil screenUtil) {
    return ListView.builder(
      itemCount: _items.length,
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Container(
          constraints: BoxConstraints.expand(
              width: screenUtil.setWidth(580),
              height: screenUtil.setHeight(200)),
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
                child: Image.network(_items[idx]['image']),
              ),
              Expanded(
                flex: 2,
                child: Flex(
                  direction: Axis.vertical,
                  children: _buildItemRightPart(idx, screenUtil),
                ),
              ),
            ],
          ),
        );
      });
  }

  List<Widget> _buildItemRightPart(int idx, ScreenUtil screenUtil) {
    var currPrice = _items[idx]['currPrice'],
        originalPrice = _items[idx]['originalPrice'],
        sellNum = _items[idx]['sellNum'],
        offerContext = _items[idx]['offerInfo']['context'],
        couponInfo = _items[idx]['offerInfo']['couponInfo'],
        couponAmt = couponInfo != null ? couponInfo['couponAmt'] : 0,
        offerType = _items[idx]['offerInfo']['offerType'],
        screenUtil = ScreenUtil();

    /// 满减优惠
    if (offerType == 'OFFER_TYPE_MJ') {
      return [
        Expanded(
          flex: 1,
          child: Text(
            _items[idx]['goodTitle'],
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

      /// 优惠券
    } else {
      return [
        Expanded(
          flex: 1,
          child: Text(
            _items[idx]['goodTitle'],
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
  }

  Future<Void> _handleRefresh() async {
    _items.clear();
    _pageNo = 0;
    return _getMoreData();
  }
}
