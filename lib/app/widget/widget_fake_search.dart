import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidgetFakeSearch extends StatelessWidget {
  final GestureTapCallback onTap;
  final ScreenUtil screenUtil = ScreenUtil();

  WidgetFakeSearch(this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: this.onTap,
        child: Container(
          height: screenUtil.setHeight(50),
          width: ScreenUtil.screenWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent)),
          child: Stack(
            children: [
              Positioned(
                top: screenUtil.setHeight(5),
                left: 0,
                child: Text('输入商品名称搜索', style: TextStyle(color: Colors.grey),),
              ),
              Positioned(
                top: screenUtil.setHeight(5),
                right: 0,
                child: Icon(Icons.search),
              ),
            ],
          ),
        ));
  }
}
