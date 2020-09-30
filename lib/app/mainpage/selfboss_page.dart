import 'package:flutter/material.dart';
import 'dart:async';

class SelfBossPage extends StatefulWidget {
  @override
  _SelfBossPageState createState() => _SelfBossPageState();
}

class _SelfBossPageState extends State<SelfBossPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true; // 保持底部切换状态不变





  @override
  Widget build(BuildContext context) {
      return Container(
        child: Text('xxx'),
      );
  }


}
