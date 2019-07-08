import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import '../model/jsonEntity.dart';

const WEB_SERVER_BASE = 'http://127.0.0.1:3000';
const WEB_SERVER_ADDR = 'http://user1-node.nb-chain.net';

const SUCCESS = 1;
const FAILED = 0;
const TEENOTREADY = -1;

// SUCCESS = 1
// FAILED = 0
// TEENOTREADY = -1
// VEIRYSING_OK = True
// VEIRYSING_NG = False

// void get_wallet() async {
//   final url = WEB_SERVER_BASE + '/get_wallet';
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     final _json = json.decode(response.body);
//     // final wallet = TeeWallet.fromJson(_json);
//     print('wallet:${_json}');
//   } else {
//     throw Exception('fail to load get_wallet');
//   }
// }
Future<TeeWallet> getWallet() async {
  final url = WEB_SERVER_BASE + '/get_wallet';
  final res = await http.get(url);
  TeeWallet wallet;
  if (res.statusCode == 200) {
    final _json = json.decode(res.body);
    if (_json['status'] == SUCCESS) {
      wallet = TeeWallet.fromJson(_json['msg']);
      return wallet;
    }
  }
  return wallet;
}

Future<TeeSign> getSign(String payload) async {
  //tee签名
  final url = 'http://127.0.0.1:3000/get_sign';
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

// final url_verify_sign = 'http://127.0.0.1:3000/verify_sign';
// final verify_sign_params = {'data': s, 'sig': teeSign.msg};
// final response_verify_sign =
//     await http.post(url_verify_sign, body: verify_sign_params);
// if (response_verify_sign.statusCode == 200) {
//   final verify_sign_result = json.decode(response_verify_sign.body);
//   TeeVerifySign teeVerifySign =
//       TeeVerifySign.fromJson(verify_sign_result);
//   if (teeVerifySign.status == 0) {
//     print('verify sign failed');
//     return;
//   } else if (teeVerifySign.status == 1) {
//     print('verify sign success');
//   }
// }

void get_block() async {
  final url = WEB_SERVER_BASE + '/get_block';
  // final response=await http.post(url,body: null);
  final response = await http.post(url);
  print('response body:${response.body}');
}
