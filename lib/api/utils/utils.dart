import 'dart:convert';
import 'package:hex/hex.dart';

final hexEn = const HexEncoder();
final hexDe = const HexDecoder();

List<int> hexStrToBytes(String hexStr) {
  return hexDe.convert(hexStr);
}

String bytesToHexStr(List<int> bytes) {
  return hexEn.convert(bytes);
}

String bytesToStr(List<int> bytes) {
  return utf8.decode(bytes);
}

/*
 * 将字符串转为(固定长度)的bytes类型
 */
List<int> strToBytes(String str, {int length}) {
  List<int> list = new List<int>();
  List<int> bytes = utf8.encode(str);
  list.addAll(bytes);
  if (length == null) {
    return list;
  } else {
    if (bytes.length > length) throw RangeError('strToBytes range error');
    for (var i = bytes.length; i < length; i++) {
      list.add(0);
    }
    return list;
  }
}

// printhexStr(List<int> list) {
//   var newlist = StringBuffer();
//   for (var i = 0; i < list.length; i++) {
//     var s = list[i].toRadixString(16);
//     if (s.length == 1) {
//       s = '0' + s;
//     }
//     newlist.write(s);
//   }
//   print('newlist:${newlist}---${newlist.length}');
// }
