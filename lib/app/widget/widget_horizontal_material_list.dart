import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zdk_app/app/common/api.dart';
import 'package:zdk_app/app/common/utils.dart';

class WidgetHorizontalMaterialList extends StatefulWidget {
  WidgetHorizontalMaterialList();

  @override
  State<StatefulWidget> createState() {
    return _WidgetHorizontalMaterialListState();
  }
}

class _WidgetHorizontalMaterialListState
    extends State<WidgetHorizontalMaterialList> {
  @override
  Widget build(BuildContext context) {
    var screenUtil = ScreenUtil();
    Map<String, dynamic> param = {'pageNo': 0, 'materialId': Utils.ssrxMi};
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 1,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: screenUtil.setHeight(10),
                child: Wrap(
                  spacing: screenUtil.setWidth(5),
                  children: [
                    Icon(
                      Icons.whatshot,
                      color: Colors.red,
                    ),
                    Text(
                      '大家都在买',
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: screenUtil.setHeight(10),
                child: Wrap(
                  children: [
                    GestureDetector(
                      child: Text(
                        '查看更多',
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.w100, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, 'ssrx', arguments: {
                          'apiMethod': Api.getInstance().getSsrx,
                          'title': '实时热销',
                          'materialId': Utils.ssrxMi
                        });
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Utils.createFutureBuilder(Api.getInstance().getSsrx(param),
              (goods) {
            return ListView.builder(
              itemCount: (goods as List).length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, idx) {
                String price = goods[idx]['currPrice'],
                    sellNum = goods[idx]['sellNum'];
                return Container(
                  constraints: BoxConstraints.expand(
                      width: screenUtil.setWidth(200),
                      height: screenUtil.setHeight(100)),
                  padding: EdgeInsets.only(left: screenUtil.setWidth(5)),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Image.network(goods[idx]['image']),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: screenUtil.setHeight(5)),
                          child: Text(
                            goods[idx]['goodTitle'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: screenUtil.setHeight(5)),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Text(
                                  "￥$price",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: screenUtil.setSp(20),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Text(
                                  "销量:$sellNum",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: screenUtil.setSp(20),
                                      fontWeight: FontWeight.w200),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        )
      ],
    );
  }
}
