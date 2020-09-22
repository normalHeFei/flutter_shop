import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_wiget.dart';
import 'package:zdk_app/app/common/config/Themes.dart';

class XYApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return new MaterialApp(
      title: '晃晃の券',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? Themes.kIOSTheme
          : Themes.kDefaultTheme,
      home: MainWidget(),
    );
  }
}
