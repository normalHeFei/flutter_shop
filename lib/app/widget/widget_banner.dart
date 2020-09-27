import 'dart:async';

import 'package:flutter/material.dart';

class WidgetBanner extends StatefulWidget {
  final double height;
  final Curve curve;
  final Function onclick;
  final List datas;

  WidgetBanner(
      {this.datas,
      /// 200
      this.height,
      this.curve = Curves.linear,
      this.onclick})
      : assert(datas != null),
        assert(height != null);

  @override
  _WidgetBannerState createState() => _WidgetBannerState();
}

class _WidgetBannerState extends State<WidgetBanner> {
  PageController _pageController;
  int _currIdx;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _currIdx = widget.datas.length;
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 3), _scroll);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildPageView(),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    var length = widget.datas.length;
    return Container(
         color: Colors.white,
      child: Positioned(
        bottom: 10,
        child: Row(
          children: widget.datas.map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: ClipOval(
                child: Container(
                  width: 8,
                  height: 8,
                  color: s == widget.datas[_currIdx % length]
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    var length = widget.datas.length;
    return Container(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onPanDown: (details) {},
            onTap: widget.onclick(widget.datas[index]),
            child: Image.network(
              widget.datas[index % length]['image'] as String,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  //定时滚动
  void _scroll(Timer timer) {
    if (_currIdx == widget.datas.length) {
      _currIdx = 0;
    }
    if(_pageController.positions.length > 0){
      _pageController.animateToPage(_currIdx,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
      _currIdx++;
    }
  }
}
