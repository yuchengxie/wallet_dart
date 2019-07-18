import 'package:buffer/buffer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nbc_wallet/api/bluetooth/formatcmd.dart';
import 'package:nbc_wallet/api/bluetooth/pseudoWallet.dart';
import 'package:nbc_wallet/api/utils/utils.dart';
import 'dart:convert';
import '../model/jsonEntity.dart';

const SUCCESS = 1;
// const FAILED = 0;
// const TEENOTREADY = -1;
PseudoWallet gPseudoWallet = PseudoWallet();
String appSelectID = "D196300077130010000000020101";
MethodChannel methodChannel = MethodChannel('hzf.bluetooth');
EventChannel eventChannel = EventChannel('hzf.bluetoothState');
//test
// const String PYTHON_SERVER = 'http://192.168.1.6:3000';
const String PYTHON_SERVER = 'http://192.168.1.103:3000';

Future<String> verifPIN(String pinCode) async {
  String cmdPinCode = formatPinCode(pinCode);
  return await transmit(cmdPinCode);
}

Future<String> sign(String pinCode, String payload) async {
  String cmdSign = formatPayloadToSign(pinCode, payload);
  String res = await transmit(cmdSign);
  return res;
}

Future<String> getPubAddr() async {
  return await transmit(CMD_PUB_ADDR);
}

Future<String> getPubKey() async {
  return await transmit(CMD_PUB_KEY);
}

Future<String> getPubKeyHash() async {
  return await transmit(CMD_PUB_KEY_HASH);
}

Future<void> connectBlueTooth(String bleName, String pinCode) async {
  try {
    await methodChannel.invokeMethod('connectBlueTooth', [bleName, pinCode]);
  } on PlatformException {}
}

Future<void> disConnectBlueTooth() async {
  try {
    methodChannel.invokeMethod('disConnectBlueTooth');
  } on PlatformException {
    return "error";
  }
}

Future<String> selectApp(String appSelectID) async {
  try {
    String res = await methodChannel.invokeMethod('selectApp', [appSelectID]);
    return res;
  } on PlatformException {
    return 'error';
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

Future<TeeSign> getSign(String payload) async {
  //tee签名
  final url = PYTHON_SERVER + '/get_sign2';
  final params = {'payload': payload, 'pincode': '000000'};
  final res = await http.post(url, body: params);
  TeeSign teeSign;
  if (res.statusCode == 200) {
    final _json = json.decode(res.body);
    if (_json['status'] == SUCCESS) {
      teeSign = TeeSign.fromJson(_json);
      print('>>> tee_sign:${teeSign.msg}');
      return teeSign;
    }
  }
  return teeSign;
}

Future<TeeVerifySign> verifySign(
    String payload, String sig, String pubkey) async {
  //tee签名
  final url = PYTHON_SERVER + '/verify_sign2';
  final params = {'data': payload, 'sig': sig, 'pubkey': pubkey};
  final res = await http.post(url, body: params);
  TeeVerifySign teeVerifySign;
  if (res.statusCode == 200) {
    final _json = json.decode(res.body);
    if (_json['status'] == SUCCESS) {
      teeVerifySign = TeeVerifySign.fromJson(_json);
      print('>>> tee_sign:${teeVerifySign.msg}');
      return teeVerifySign;
    } else {
      print('verify sign failed');
      return null;
    }
  }
  return teeVerifySign;
}

String compressPublicKey(String pubkey) {
  print('pubkey:$pubkey-${pubkey.length}');
  List<int> p = hexStrToBytes(pubkey);
  print('p:$p-${p.length}');
  if (p[0] != 4 || p.length != 65) {
    print('invalid uncompressed public key');
    return '';
  }
  List<int> s = p.sublist(p.length - 1);
  int n = bytesToNum(s);
  int a = n & 0x01;
  int b = 0x02 + a;
  ByteDataWriter writer = ByteDataWriter();
  writer.writeUint8(b);
  writer.write(p.sublist(1, 33));
  List<int> d = writer.toBytes();
  var e = bytesToHexStr(d);
  return e;
}

int bytesToNum(List<int> bytes) {
  num total = 0;
  for (int i = bytes.length - 1; i >= 0; i--) {
    var t = bytes[i];
    var a = t << (bytes.length - i - 1) * 8;
    total += a;
  }
  return total;
}

// void get_block() async {
//   final url = WEB_SERVER_BASE + '/get_block';
//   // final response=await http.post(url,body: null);
//   final response = await http.post(url);
//   print('response body:${response.body}');
// }
