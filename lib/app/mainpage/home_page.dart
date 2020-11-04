import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return  _HomePageState();
  }

}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
     return  Center(
        child: const Text('home 开发中,尽情期待'),
     );
  }

}