import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nbc_wallet/api/bluetooth/formatcmd.dart';
import 'package:nbc_wallet/api/bluetooth/pseudoWallet.dart';
import 'dart:convert';
import '../model/jsonEntity.dart';

// const WEB_SERVER_BASE = 'http://127.0.0.1:3000';
const WEB_SERVER_ADDR = 'http://raw0.nb-chain.net';
const SUCCESS = 1;
const FAILED = 0;
const TEENOTREADY = -1;
PseudoWallet gPseudoWallet = PseudoWallet();
String appSelectID = "D196300077130010000000020101";
MethodChannel methodChannel = MethodChannel('hzf.bluetooth');
EventChannel eventChannel = EventChannel('hzf.bluetoothState');

Future<String> selectApp(String appSelectID) async {
  try {
    String res = await methodChannel.invokeMethod('selectApp', [appSelectID]);
    return res;
  } on PlatformException {
    return 'error';
  }
}

Future<String> verifPIN(String pinCode) async {
  String cmdPinCode = formatPinCode(pinCode);
  return await transmit(cmdPinCode);
}

Future<String> sign(String pinCode, String payload) async {
  String cmdSign = formatPayloadToSign(pinCode, payload);
  return await transmit(cmdSign);
}

Future<String> getPubAddr() {
  return null;
}

Future<String> getPubKey() {
  return null;
}

Future<String> getPubKeyHash() {
  return null;
}

Future<String> connectBlueTooth(String bleName, String pinCode) async {
  try {
    String res = await methodChannel
        .invokeMethod('connectBlueTooth', [bleName, pinCode]);
    return res;
  } on PlatformException {
    return 'error';
  }
}

Future<void> disConnectBlueTooth() async {
  try {
    methodChannel.invokeMethod('disConnectBlueTooth');
  } on PlatformException {
    return "error";
  }
}

Future<String> transmit(String sendStr) async {
  try {
    String res = await methodChannel.invokeMethod('transmit', [sendStr]);
    return res;
  } on PlatformException {
    return 'error';
  }
}

// Future<TeeWallet> getWallet() async {
//   final url = WEB_SERVER_BASE + '/get_wallet';
//   final res = await http.get(url);
//   TeeWallet wallet;
//   if (res.statusCode == 200) {
//     final _json = json.decode(res.body);
//     if (_json['status'] == SUCCESS) {
//       wallet = TeeWallet.fromJson(_json['msg']);
//       return wallet;
//     }
//   }
//   return wallet;
// }

// Future<TeeSign> getSign(String payload) async {
//   //tee签名
//   final url = 'http://127.0.0.1:3000/get_sign';
//   final params = {'payload': payload, 'pincode': '000000'};
//   final res = await http.post(url, body: params);
//   TeeSign teeSign;
//   if (res.statusCode == 200) {
//     final _json = json.decode(res.body);
//     if (_json['status'] == SUCCESS) {
//       teeSign = TeeSign.fromJson(_json);
//       print('>>> tee_sign:${teeSign.msg}');
//       return teeSign;
//     }
//   }
//   return teeSign;
// }

Future<TeeVerifySign> verifySign(String payload, String sig) async {
  //tee签名
  final url = 'http://127.0.0.1:3000/verify_sign';
  final params = {'data': payload, 'sig': sig};
  final res = await http.post(url, body: params);
  TeeVerifySign teeVerifySign;
  if (res.statusCode == 200) {
    final _json = json.decode(res.body);
    if (_json['status'] == SUCCESS) {
      teeVerifySign = TeeVerifySign.fromJson(_json);
      print('>>> tee_sign:${teeVerifySign.msg}');
      return teeVerifySign;
    } else {
      print('>>> sign err');
    }
  }
  return teeVerifySign;
}

// void get_block() async {
//   final url = WEB_SERVER_BASE + '/get_block';
//   // final response=await http.post(url,body: null);
//   final response = await http.post(url);
//   print('response body:${response.body}');
// }
