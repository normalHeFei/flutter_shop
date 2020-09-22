import 'package:flutter/material.dart';

class CatTab extends Tab {
  String _materialId;

  CatTab(String text, this._materialId) : super(text: text);

  String get materialId => _materialId;
}
