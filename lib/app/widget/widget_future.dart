import 'package:flutter/cupertino.dart';
import 'package:zdk_app/app/widget/widget_progress.dart';

class WidgetFuture extends StatefulWidget {
  final Function widgetBuilder;
  final Future future;

  WidgetFuture(this.widgetBuilder, this.future);

  @override
  State<StatefulWidget> createState() {
    return WidgetFutureState();
  }
}

class WidgetFutureState extends State<WidgetFuture> {
  dynamic futureRst;

  @override
  Widget build(BuildContext context) {
    if (futureRst == null) {
      return WidgetProgress('正在加载..');
    }
    return widget.widgetBuilder(futureRst);
  }

  @override
  void initState() {
    super.initState();
    widget.future.then((value) {
      setState(() {
        futureRst = value;
      });
    });
  }
}
