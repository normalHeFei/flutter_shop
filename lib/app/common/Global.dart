import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class Global {
  static SharedPreferences _sharePre;
  static const _encoder = JsonEncoder();
  static const _decoder = JsonDecoder();

  Global._internal();

  static Future initData() async {
    if (_sharePre == null) {
      _sharePre = await SharedPreferences.getInstance();
    }
    var lms = await Api.getInstance().queryCats();
    return _sharePre.setString('cats', _encoder.convert(lms));
  }

  static dynamic get(String key) {
    return _decoder.convert(_sharePre.get(key));
  }
}
