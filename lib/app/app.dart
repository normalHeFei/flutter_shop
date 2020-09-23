import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zdk_app/app/widget/widget_vertical_material_list.dart';
import 'main_wiget.dart';
import 'package:zdk_app/app/common/config/Themes.dart';

class XYApp extends StatelessWidget {

  /// all routes here
  final routesConfig = {
    '/home/ssrx': (context, {arguments}) => WidgetVerticalMaterialList(
          future: arguments['future'],
          title: arguments['title'],
        )
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '晃晃の券',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? Themes.kIOSTheme
          : Themes.kDefaultTheme,
      home: MainWidget(),
      onGenerateRoute: (runtimeSettings) {
        Function pageBuilder = this.routesConfig[runtimeSettings.name];
        return MaterialPageRoute(
            builder: (context) =>
                pageBuilder(context, runtimeSettings.arguments));
      },
    );
  }
}
