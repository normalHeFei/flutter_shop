import 'package:flutter/material.dart';

import 'good_detail.dart';

class GoodItem extends StatelessWidget {

  Map _goodModel;

  GoodItem(this._goodModel);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        child: _widgetItem(),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return GoodInfo(index: '1');
          }));
        });
  }

  _widgetItem() {
     return  Column(

     );
  }
}
