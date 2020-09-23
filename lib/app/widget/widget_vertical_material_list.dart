import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/utils.dart';

typedef materialListApiMethod = Future Function({Map param});

class WidgetVerticalMaterialList extends StatefulWidget {
  Future _future;
  String _title;

  WidgetVerticalMaterialList({Future future, String title}) {
    this._future = future;
    this._title = title;
  }

  @override
  _WidgetVerticalMaterialListState createState() =>
      _WidgetVerticalMaterialListState();
}

class _WidgetVerticalMaterialListState
    extends State<WidgetVerticalMaterialList> {

  final int _pageCount = 5;
  final int _currPage = 0;


  @override
  Widget build(BuildContext context) {
    var screenUtil = ScreenUtil();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget._title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenUtil.setSp(20),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView.builder(
          itemCount:  _pageCount,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, idx) {
            return Container(
                constraints: BoxConstraints.expand(width: ScreenUtil.screenWidth, height: screenUtil.setHeight(200)) ,
                padding: EdgeInsets.fromLTRB(screenUtil.setWidth(5), screenUtil.setHeight(5),screenUtil.setWidth(5), screenUtil.setHeight(5)) ,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                     Expanded(
                       flex: 1,
                       child: ,
                     )
                  ],
                ),
            );
      }),
    );
  }


}
