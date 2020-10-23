import 'package:flutter/material.dart';
import 'package:zdk_app/app/common/Global.dart';
import './app/app.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'test',
      home: Scaffold(

      ),
    );
  }

}
