import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Utils {
  /// 物料常量
  static String  ssrxMi = "28026";

  static FutureBuilder createFutureBuilder(
      Future future, Function widgetBuilder) {
    return FutureBuilder(
      future: future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return widgetBuilder(snapshot.data);
          }
        } else {
          return SizedBox(
            width: ScreenUtil().setWidth(25),
            height: ScreenUtil().setHeight(25),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  static StreamBuilder createStreamBuilder(
      List<Future> futures, Function widgetBuilder) {
    return StreamBuilder(
      stream: Stream.fromFutures(futures),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return widgetBuilder(snapshot.data);
          }
        } else {
          return SizedBox(
            width: ScreenUtil().setWidth(25),
            height: ScreenUtil().setHeight(25),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
