import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidgetProgress extends StatelessWidget {
  final String loadingText;

  WidgetProgress(this.loadingText);

  @override
  Widget build(BuildContext context) {
    var screenUtil = ScreenUtil();
    return Center(
        child: Container(
      padding: const EdgeInsets.all(10.0),
      constraints: BoxConstraints.expand(
          width: screenUtil.setWidth(200), height: screenUtil.setHeight(200)),
      decoration: BoxDecoration(
          //黑色背景
          color: Colors.black87,
          //圆角边框
          borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        //控件里面内容主轴负轴剧中显示
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        //主轴高度最小
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          Text(
            loadingText,
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    ));
  }
}
