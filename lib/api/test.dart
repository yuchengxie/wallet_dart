import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import './model/jsonEntity.dart';
import 'transfer.dart';

String main() {
  getQueryTxnHashResult(
          '2a70905f28f2cb8ef6f9a4d1a055709df733fd5cf350a8038a973cd409f74f37')
      .then((res) {
    print('完成后接收:$res');
  });
}

Future<Response> test01() async {
  return await http.get('http://www.baidu.com');
}

void verifySign() async {
  String s =
      '01000000019e4696a0c3e176d25764dc1807e3296f497005c6d4813586f2795ecd44441d07010000002876b8230000a05d97094d5e277395ef1f0487c8dd93730360cad84d379dafc28f004960dada00b7acffffffff0200e1f505000000002876b8230000e5c7b20d5b5037f86e9861cd8795be42e8093c61bd36256a2b5a22df6508a8ba00b7ac54143199040000002876b823dadaa05d97094d5e277395ef1f0487c8dd93730360cad84d379dafc28f004960dada00b7ac0000000001000000';
  while (true) {
    final url_sign = 'http://127.0.0.1:3000/get_sign';
    final sign_params = {'payload': s, 'pincode': '000000'};
    final response_sign = await http.post(url_sign, body: sign_params);
    if (response_sign.statusCode != 200) {
      print('sign err');
      return;
    }
    final _json_sign = json.decode(response_sign.body);
//    print('_json_sign:${_json_sign}');
    TeeSign teeSign = TeeSign.fromJson(_json_sign);
    print('>>> tee_sign:${teeSign.msg}');
    sleep(Duration(seconds: 3));
  }
}

List<int> trimCommand(List<int> bytes) {
  int index = bytes.indexOf(0);
  var tempList = new List<int>.from(bytes);
  print(index);
  print(bytes.length);
  tempList..removeRange(index, tempList.length);
  print('templist:${tempList}');
  return tempList;
}
