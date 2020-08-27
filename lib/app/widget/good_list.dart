import 'package:flutter/material.dart';
import 'good_list_item.dart';

class GoodList extends StatefulWidget {

  String text;
  Color  color;
  GoodList(this.text, {this.color});

  _GoodListState createState() => new _GoodListState();
}

class _GoodListState extends State<GoodList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      top: false,
      bottom: false,
      child: ListView.separated(
          itemBuilder: _goodItemBuilder,
          separatorBuilder: (context, index) => Divider(),
          itemCount: 10),
    );
  }

  Widget _goodItemBuilder(BuildContext context, int index) {

    return GoodItem({});
  }
}
