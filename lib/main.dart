import 'package:flutter/material.dart';
import 'package:zdk_app/app/common/Global.dart';
import './app/app.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  debugPaintSizeEnabled = false; //打开视觉调试开关
  WidgetsFlutterBinding.ensureInitialized();
  Global.initData().then((value) => runApp(XYApp()));
}
