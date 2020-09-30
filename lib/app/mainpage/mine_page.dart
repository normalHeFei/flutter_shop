import 'package:flutter/material.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持底部切换状态不变

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('xxx'),
    );
  }
}
