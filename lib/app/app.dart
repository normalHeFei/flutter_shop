import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zdk_app/app/widget/widget_vertical_material_list.dart';
import 'main_wiget.dart';
import 'package:zdk_app/app/common/config/Themes.dart';

class XYApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'test',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? Themes.kIOSTheme
          : Themes.kDefaultTheme,

      routes: {
         '/': (context){
            return MainWidget();
         },
        /// 实时热销
        'ssrx': (context) {
          Map arguments = ModalRoute.of(context).settings.arguments;
          return WidgetVerticalMaterialList(
              apiMethod: arguments['apiMethod'] as Function,
              title: arguments['title'],
              materialId: arguments['materialId']);
        },
      },
    );
  }
}
