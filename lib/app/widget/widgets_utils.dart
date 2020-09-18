import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class WidgetUtils{

   static FutureBuilder getDefaultFutureBuilder(Future future, Function widgetBuilder) {
    return FutureBuilder(
      future: future,
      builder: (context, snap) {
        if (snap.hasError) {
          print('加载出错');
        }
        if (snap.connectionState == ConnectionState.done) {
          return widgetBuilder(snap.data);
        }
        return Center(child: CupertinoActivityIndicator());
      },
    );
  }
}




