
import '../main.dart';
import 'package:flutter/material.dart';
import '../pages/my.dart';
import '../pages/choose.dart';
import '../pages/resource.dart';
import 'package:demo/pages/vippage.dart';
import 'navigation/titled_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _createIndex = 0;
  List<Widget> list = List();

  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('zhanghao') == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  void initState() {
    _incrementCounter();
    list
      ..add(ResourcePage())
      ..add(Choose())
      ..add(VipPage())
      ..add(My());
    super.initState();
  }

  final List<TitledNavigationBarItem> items = [
    TitledNavigationBarItem(title: '首页', icon: FontAwesomeIcons.home),
    TitledNavigationBarItem(title: '筛选', icon: FontAwesomeIcons.search),
    TitledNavigationBarItem(title: 'VIP', icon: FontAwesomeIcons.lemon),
    TitledNavigationBarItem(title: '我的', icon: FontAwesomeIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      IndexedStack(
        index: _createIndex,
        children: list,
      ),
      //list[_createIndex],
      bottomNavigationBar: TitledBottomNavigationBar(
        reverse: navBarMode,
        curve: Curves.easeInBack,
        items: items,
        activeColor: Colors.red,
        inactiveColor: Colors.blueGrey,
        currentIndex: _createIndex,
        onTap: (int index) {
          setState(() {
            _createIndex = index;
          });
        },
      ),
    );
  }
}
