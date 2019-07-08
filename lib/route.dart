import 'package:flutter/material.dart';
import 'package:nbc_wallet/pages/tran/qrcode.dart';
import 'package:nbc_wallet/pages/tran/recordpage.dart';
import 'package:nbc_wallet/pages/tran/scanfcode.dart';
import 'package:nbc_wallet/pages/tran/transferpage.dart';
import 'package:nbc_wallet/pages/tran/txndeatails.dart';
import 'package:nbc_wallet/pages/tabs.dart';

final _routes = {
  '/': (context) => Tabs(),
  '/assetRecordPage': (context) => AssetRecordPage(),
  '/transferPage': (context) => TransferPage(),
  '/txnDetailsPage': (context) => TxnDetailsPage(),
  '/qrcode': (context) => QRCodePage(),
  '/scanfcode':(context)=>ScanfCodePage(),
};

var onGenerateRoute = (RouteSettings settings) {
  String _routeName = settings.name;
  final Function pageControllerBuilder = _routes[_routeName];
  print(_routeName);
  if (pageControllerBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
        builder: (context) =>
            pageControllerBuilder(context, arguments: settings.arguments),
      );
      return route;
    } else {
      final Route route = MaterialPageRoute(
          builder: (context) => pageControllerBuilder(context));
      return route;
    }
  }
};
