import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StateModel with ChangeNotifier {
  // String _recvAddr = '';
  String _recvAddr = '1118hfRMRrJMgSCoV9ztyPcjcgcMZ1zThvqRDLUw3xCYkZwwTAbJ5o';
  double _amount = 0.01;
  String _txnHash = '';
  String _lastUock = '';
  String _tranState = '';
  String get recvAddr => _recvAddr;
  double get amount => _amount;
  String get txnHash => _txnHash;
  String get lastUock => _lastUock;
  String get tranState => _tranState;

  //theme
  WalletTheme _walletTheme=WalletTheme(brightness: Brightness.light,appBarbackColor: Colors.cyan);
  WalletTheme get walletTheme => _walletTheme;

  void updateAddr(value) {
    _recvAddr = value;
    notifyListeners();
  }

  void updateAmount(value) {
    _amount = value;
    notifyListeners();
  }

  void updateTxnHash(value) {
    _txnHash = value;
    notifyListeners();
  }

  void updateLastUock(value) {
    _lastUock = value;
    notifyListeners();
  }

  void updateTranState(value) {
    _tranState = value;
    notifyListeners();
  }

  void updateTheme(value) {
    _walletTheme = value;
    notifyListeners();
  }
}

class WalletTheme {
  Brightness brightness=Brightness.dark;
  Color appBarbackColor=Colors.cyan;
  WalletTheme({this.brightness,this.appBarbackColor});
}
