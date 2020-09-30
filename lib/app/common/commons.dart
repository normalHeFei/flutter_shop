import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Utils {
  /// 物料常量
  static String ssrxMi = "28026";

  static FutureBuilder createFutureBuilder(
      Future future, Function widgetBuilder) {
    return FutureBuilder(
      future: future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            if (snapshot.data == null) {
              return Container(
                child: Text('请求数据失败,请检查网络连接'),
                alignment: Alignment.center,
              );
            }
            return widgetBuilder(snapshot.data);
          }
        } else {
          return SizedBox(
            width: ScreenUtil().setWidth(10),
            height: ScreenUtil().setHeight(10),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
