import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class Api {
  static Api _instance;
  Dio _dio;
  static const String baseUrl = 'http://192.168.7.133:8080/';

  Api._internal(this._dio);

  factory Api.getInstance() => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = Api._internal(Dio(BaseOptions(
         baseUrl: baseUrl,
         connectTimeout: 5000
      )));
    }
    return _instance;
  }

  Future _invoke(url, {Map param}) async {
    return _dio
        .get(baseUrl + url, queryParameters: param)
        .then((value) => _decode(value))
        .catchError((ex, stack) {
      print('出错: ex: $ex,  stack是: $stack');
    });
  }

  Future _decode(Response res) {
    var rst = jsonDecode(res.toString());
    return Future.value(rst['data']);
  }

  Future getBanners() async {
    return _invoke('shop/listBanners');
  }

  Future getLms() async {
    return _invoke('shop/lms');
  }


  Future geSsrx() async {
    return _invoke('shop/ssrx');
  }
}
