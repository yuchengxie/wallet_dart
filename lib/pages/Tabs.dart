import 'package:flutter/material.dart';
import 'package:nbc_wallet/pages/tabpages/assetPage.dart';
import 'package:nbc_wallet/pages/tabpages/findPage.dart';
import 'package:nbc_wallet/pages/tabpages/marketPage.dart';
import 'package:nbc_wallet/pages/tabpages/personalPage.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  List _list = [AssetPage(), MarketPage(), FindPage(), PersonalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _list[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.web_asset), title: Text('资产')),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), title: Text('行情')),
          BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('发现')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我')),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
