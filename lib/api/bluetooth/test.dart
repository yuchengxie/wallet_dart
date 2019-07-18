// import 'package:buffer/buffer.dart';
// import 'package:nbc_wallet/api/utils/utils.dart';

// main(List<String> args) {
//   print('123');
//   String s1 =
//       '040959255842298e94133acf1707674ae55cc4e59b4387d2ee4bcd1759b0e124830e3ee454e8e8324b4a503ca067ef986e6bc97acad42806b938f077e13bd72eba';
//   compress_public_key(s1);
//   // String s2='140e';
//   // List<int> p = hexStrToBytes(s2);
//   // print('p:$p');
//   // bytesToNum(p);
// }

// String compress_public_key(String pubkey) {
//   print('pubkey:$pubkey-${pubkey.length}');
//   List<int> p = hexStrToBytes(pubkey);
//   print('p:$p-${p.length}');
//   if (p[0] != 4 || p.length != 65) {
//     print('invalid uncompressed public key');
//     return '';
//   }
//   List<int> s = p.sublist(p.length - 1);
//   int n = bytesToNum(s);
//   int a = n & 0x01;
//   int b = 0x02 + a;
//   ByteDataWriter writer = ByteDataWriter();
//   writer.writeUint8(b);
//   writer.write(p.sublist(1, 33));
//   List<int> d = writer.toBytes();
//   var e = bytesToHexStr(d);
//   return e;
// }

// int bytesToNum(List<int> bytes) {
//   num total = 0;
//   for (int i = bytes.length - 1; i >= 0; i--) {
//     var t = bytes[i];
//     // print('index:$');
//     var a = t << (bytes.length - i - 1) * 8;
//     print('index:$i,a:$a');
//     total += a;
//   }
//   print('total:$total');
//   return total;
// }
