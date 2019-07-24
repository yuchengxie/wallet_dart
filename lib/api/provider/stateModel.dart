import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../bluetooth/blueservice.dart';

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

  String _blueState = "0";
  String get blueState => _blueState;

  StateModel(){
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  _onEvent(Object event) {
    Map dic=event;
    _blueState=dic["state"];
  }

  _onError(Object error) {
    _blueState='blue connect:unknow';
  }


  //theme
  // WalletTheme _walletTheme=WalletTheme(brightness: Brightness.light,appBarbackColor: Colors.cyan);
  WalletTheme _walletTheme = WalletTheme(brightness: Brightness.dark);
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
  Brightness brightness = Brightness.dark;
  // Color appBarbackColor=Colors.white;
  // Color appBarbackColor=null;
  // WalletTheme({this.brightness,this.appBarbackColor});
  // WalletTheme({this.brightness,this.appBarbackColor});
  WalletTheme({this.brightness});
}
