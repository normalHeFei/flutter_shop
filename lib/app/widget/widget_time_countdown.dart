import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CountDownType { day, hour, min, second }

class TimeUnit {
  final CountDownType countDownType;

  final num time;

  const TimeUnit(this.countDownType, this.time);
}

// ignore: must_be_immutable
class WidgetTimeCountDown extends StatefulWidget {
  TimeUnit _timeUnit;
  String _prefix;
  String _suffix;

  WidgetTimeCountDown.withPrefix(this._timeUnit, this._prefix);

  WidgetTimeCountDown.withSuffix(this._timeUnit, this._suffix);

  @override
  WidgetTimeCountDownState createState() => WidgetTimeCountDownState();
}

class WidgetTimeCountDownState extends State<WidgetTimeCountDown>
    with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: _buildInner(),
    );
  }

  List<Widget> _buildInner() {
    if (widget._timeUnit.countDownType == CountDownType.day) {

    }
  }

}

class _WidgetCountDownUnit extends StatefulWidget {
  final num _number;
  final String _desc;

  _WidgetCountDownUnit(this._number, this._desc);

  @override
  State<StatefulWidget> createState() {
    return _WidgetCountDownUnitState();
  }

}

class _WidgetCountDownUnitState extends State<_WidgetCountDownUnit> {

  @override
  Widget build(BuildContext context) {
    var screenUtil = ScreenUtil();
    return Wrap(
      direction: Axis.horizontal,
      children: [
        Container(
          constraints: BoxConstraints.expand(
              width: screenUtil.setWidth(30), height: screenUtil.setHeight(30)),
          color: Colors.grey,
          child: Text(
            widget._number.toString(),
            style: TextStyle(
                fontSize: screenUtil.setSp(25),
                color: Colors.black26
            ),
          ),
        ),
        Text(
          widget._desc.toString(),
          style: TextStyle(
              fontSize: screenUtil.setSp(25),
              color: Colors.grey
          ),
        ),
      ],
    );
  }

}
