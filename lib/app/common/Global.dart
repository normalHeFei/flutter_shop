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

  static Future<bool> append(String key, String value, {maxLength = 3}) {
    var storeValue = _sharePre.get(key);
    if (storeValue == null) {
      return _sharePre.setStringList(key, [value]);
    }
    if (storeValue is List<String>) {
      var indexOf = storeValue.indexOf(value);
      if (indexOf == -1) {
        if (storeValue.length == maxLength) {
          storeValue.removeLast();
        }
        storeValue.insert(0, value);
        return _sharePre.setStringList(key, storeValue);
      }

      /// 首位的话,无需调整
      if (indexOf == 0) {
        return Future.value(true);
      } else {
        storeValue.removeAt(indexOf);
        storeValue.insert(0, value);
        return _sharePre.setStringList(key, storeValue);
      }
    }
    throw Exception('key $key 对应值不是 List<String> 类型, 不可调用此方法');
  }

  /// 删除字符列表项
  static bool delStringItem(String key, String deleted) {
    var stringList = _sharePre.getStringList(key);
    if (stringList.isNotEmpty) {
      stringList.remove(deleted);
      _sharePre.setStringList(key, stringList);
      return true;
    }
    return false;
  }

  static List<String> getStringList(String key) {
    return _sharePre.getStringList(key);
  }
}
