import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class Api {
  static Api _instance;
  Dio _dio;
  static const String baseUrl = 'http://192.168.8.112:8080/';

  Api._internal(this._dio);

  factory Api.getInstance() => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = Api._internal(
          Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: 10000)));
    }
    return _instance;
  }

  Future _invoke(url, {Map param}) async {
    print('请求参数: $param');
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
    return _invoke('shop/listBanner');
  }

  Future queryCats() async {
    return _invoke('shop/queryCats');
  }

  Future pageQueryByCat(Map<String, dynamic> param) async {
    return _invoke('shop/pageQueryByCat', param: param);
  }

  Future pageQueryByKw(Map<String, dynamic> param) async {
    return _invoke('shop/pageQueryByKw', param: param);
  }

  Future queryRecommendKeywords() async {
    return _invoke('shop/queryRecommendKeywords');
  }

  Future queryPddSchemaUrl(Map<String, dynamic> param) async {
    return _invoke('shop/queryPddSchemaUrl', param: param);
  }
  Future queryTbPwd(Map<String, dynamic> param) async {
    return _invoke('shop/queryTbPwd', param: param);
  }

  Future queryHomeDynamic() async {
    return _invoke('shop/queryHomeDynamic');
  }

  Future pageQueryRecommendGoods(Map<String, dynamic> param) async {
    return _invoke('shop/pageQueryRecommendGoods');
  }
}
