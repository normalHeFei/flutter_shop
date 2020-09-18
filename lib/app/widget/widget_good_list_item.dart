import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'page_good_detail.dart';

class GoodItem extends StatelessWidget {
  Map _goodModel;

  GoodItem(this._goodModel);

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
        child: _widgetItem(),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return GoodInfo(index: '1');
          }));
        });
  }

  _widgetItem() {

    Container title =Container (
      padding: const EdgeInsets.all(6.0),
      width: 200,
      child:  Column (
        children: <Widget>[
           Text ('${_goodModel['title']}', textAlign: TextAlign.left),
        ],
      ),
    );

    Text price = Text(
      '¥${_goodModel['price']}',
      style: TextStyle(
          color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
    );
    Text originalPrice = Text(
      '¥${_goodModel['originalPrice']}',
      style: TextStyle(
          color: Colors.grey,
          fontSize: 10,
          decoration: TextDecoration.lineThrough),
    );

    Container coupon = Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.orange[700]]),
            borderRadius: BorderRadius.circular(4.0)),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          '${_goodModel['coupon']}元券',
          style: TextStyle(fontSize: 10),
        ));

    Text sales = Text('销量 ${_goodModel['Sales']}',
        style: TextStyle(fontSize: 10, color: Colors.grey));

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(3.0)),
      child: Row(
        children: [
          Container(
            child: Image.network(
              _goodModel['image'],
              width: 160,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            //fixme: 不同设备,宽度像素处理?
            constraints: BoxConstraints.expand(width: 200, height: 160),
            child: Stack(
              //指定剩余未定位元素的默认定位
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 5,
                  child: title,
                ),
                Positioned(
                  left: 5,
                  bottom: 25,
                  child: price,
                ),
                Positioned(
                  left: 5,
                  bottom: 10,
                  child: originalPrice,
                ),
                Positioned(
                  right: 5,
                  bottom: 25,
                  child: coupon,
                ),
                Positioned(
                  right: 5,
                  bottom: 10,
                  child: sales,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
