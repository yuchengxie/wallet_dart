import 'dart:typed_data';
import 'package:crypto/src/sha256.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:buffer/buffer.dart';
import 'package:http/http.dart' as http;
import './pack/pack.dart';
import './pack/unpack.dart';
import './model/jsonEntity.dart';
import './model/message.dart';
import './scripts/opscript.dart';
import './utils/utils.dart';
import 'bluetooth/blueservice.dart';

const WEB_SERVER_ADDR = 'http://raw0.nb-chain.net';
// const WEB_SERVER_ADDR = 'http://user1-node.nb-chain.net';
const TXN_PENDING = 0;
const TXN_SUCCESS = 1;
const TXN_ERROR = -1;
const S_PENDING = 'pending';
var sequence = 0,
// _wait_submit = [],
    SHEET_CACHE_SIZE = 16,
    sn,
    tx_ins2 = [],
    tx_ins_len,
    pks_out0,
// hash_type = 1,
    submit = true;
List _wait_submit = [];
int seq = 0;
List state_info;
TeeWallet _wallet;
final magic = [0xf9, 0x6e, 0x62, 0x74];
MakeSheet makesheet;
OrgSheet orgSheet;
List<int> hash_;
bool isQuery = true;

void main() {
  // query_sheet('', '');
  // transfer('', '');
}

Future<MakeSheetResult> transfer(pay_to, from_uocks) async {
  int ext_in = 0;
  bool submit = true;
  int scan_count = 0;
  int min_utxo = 0;
  int max_utxo = 0;
  int sort_flag = 0;
  int from_uocks = 0;
  makesheet = prepare_txn1_(pay_to, ext_in, submit, scan_count, min_utxo,
      max_utxo, sort_flag, from_uocks);
  print('makesheet: $makesheet');
  if (makesheet == null) return null;

  String command = 'makesheet';
  List<int> payload_makesheet = makeSheetpayload(makesheet);
  List<int> bytes_makesheet = wholePayload(payload_makesheet, command);

  String s1 = bytesToHexStr(bytes_makesheet);
  print('1准备发送数据:${s1.length}---${s1}');
  final url_sheet = WEB_SERVER_ADDR + '/txn/sheets/sheet';
  final response_sheet = await http.post(url_sheet, body: bytes_makesheet);
  if (response_sheet.statusCode != 200) {
    print('err /txn/sheets/sheet');
    return null;
  }
  List<int> orgsheet_bytes = response_sheet.bodyBytes;
  String s = bytesToHexStr(orgsheet_bytes);
  print('1接收到数据${s.length}---$s');

  orgSheet = parseOrgSheet(orgsheet_bytes);
  if (orgSheet == null) {
    print('orgSheet null');
    return null;
  }
  //获取钱包
  print("wallet: ${gPseudoWallet.pubAddr}");
//   //网络获取钱包
//   // _wallet = await getWallet();
//   _wallet = await null;
//   if (_wallet == null) {
//     print('_wallet null');
//     return null;
//   }
//   List<int> coin_hash = hexStrToBytes(_wallet.pub_hash + '00');
//   print(coin_hash);

//   var d = {};
//   var _pay_to = makesheet.pay_to;
//   for (var i = 0; i < _pay_to.length; i++) {
//     var p = _pay_to[i];
//     List<int> _add = strToBytes(p.address);
//     if (p.value != 0 || _add.sublist(0, 1) != 0x6a) {
//       Uint8List ret = decode_check(p.address).sublist(1);
//       if (ret == null) {
//         continue;
//       }
//       String ret_str = bytesToHexStr(ret);
//       d[ret_str] = p.value;
//     }
//   }

//   for (int idx = 0; idx < orgSheet.tx_out.length; idx++) {
//     var item = orgSheet.tx_out[idx];
//     if (item.value == 0 && item.pk_script.substring(0, 1) == '') {
//       continue;
//     }
// //脚本操作
//     String addr = process(item.pk_script).split(' ')[2];
//     if (addr == null) {
//       print('Error: invalid output address (idx=${idx})');
//     } else {
//       var value_ = d[addr];
//       if (value_ != null) {
//         d.remove(d[addr]);
//       } else {
//         continue;
//       }
//       if (item.value != value_) {
//         if (value_ == null && addr.substring(4) == bytesToHexStr(coin_hash)) {
//         } else {
//           print('Error: invalid output value (idx=${idx})');
//         }
//       }
//     }
//   }

//   for (var k in d.keys) {
//     print('${k}--${d[k]}');
//   }

//   var pks_out0 = orgSheet.pks_out[0].items;
//   var pks_num = pks_out0.length;
//   List<TxIn> tx_ins2 = List<TxIn>();
//   for (int idx = 0; idx < orgSheet.tx_in.length; idx++) {
//     if (idx < pks_num) {
//       TxIn tx = orgSheet.tx_in[idx];
//       int hash_type = 1;
//       Uint8List sign_payload = script_payload(pks_out0[idx], orgSheet.version,
//           orgSheet.tx_in, orgSheet.tx_out, 0, idx, hash_type);
//       String s = bytesToHexStr(sign_payload);
//       print('>>> ready sign payload:${s}---${s.length}');

//       //tee签名
//       // TeeSign teeSign = await getSign(s);
//       // if (teeSign == null) {
//       //   print('teeSign null');
//       //   return null;
//       // }
//       // TeeSign teeSign = null;
//       String _sign = await sign('000000', s);
//       //验证签名
//       // TeeVerifySign teeVerifySign = await verifySign(s, teeSign.msg);
//       TeeVerifySign teeVerifySign = await verifySign(s, _sign);
//       // TeeVerifySign teeVerifySign = null;
//       if (teeVerifySign == null) {
//         print('verify sign err,null');
//         return null;
//       }

//       // List<int> sig = new List<int>.from(hexStrToBytes(teeSign.msg))
//       //   ..addAll(CHR(hash_type));
//       // print('>>> sig:${bytesToHexStr(sig)}');

//       // List<int> sig_script = List.from(CHR(sig.length))
//       //   ..addAll(sig)
//       //   ..addAll(CHR(hexStrToBytes(_wallet.pub_key).length))
//       //   ..addAll(hexStrToBytes(_wallet.pub_key));
//       // print(
//       //     '>>> sig_script:${bytesToHexStr(sig_script)}---${bytesToHexStr(sig_script).length}');
//       // tx_ins2.add(TxIn(
//       //     prev_output: tx.prev_output,
//       //     sig_script: bytesToHexStr(sig_script),
//       //     sequence: tx.sequence));
  // }
  // }

  // Transaction txn = Transaction(
  //     version: orgSheet.version,
  //     tx_in: tx_ins2,
  //     tx_out: orgSheet.tx_out,
  //     lock_time: orgSheet.lock_time,
  //     sig_raw: '');
  // List<int> txn_payload = txnPayload(txn);
  // txn_payload = wholePayload(txn_payload, txn.command);
  // var t = bytesToHexStr(txn_payload);
  // print('txn_payload:${t} --- ${t.length}');
  // hash_ = sha256
  //     .convert(
  //         sha256.convert(txn_payload.sublist(24, txn_payload.length - 1)).bytes)
  //     .bytes;
  // print('>>> hash_:${bytesToHexStr(hash_)}');
  // state_info = [
  //   orgSheet.sequence,
  //   txn,
  //   'requested',
  //   hash_,
  //   orgSheet.last_uocks
  // ];
  // _wait_submit.add(state_info);
  // while (_wait_submit.length > SHEET_CACHE_SIZE) {
  //   _wait_submit.remove(_wait_submit[0]);
  // }

  // if (submit) {
  //   int unsign_num = orgSheet.tx_in.length - pks_num;
  //   if (unsign_num != 0) {
  //     print('Warning: some input not signed: ${unsign_num}');
  //     return null;
  //   } else {
  //     String url_txn = WEB_SERVER_ADDR + '/txn/sheets/txn';
  //     var responseTxn = await http.post(url_txn, body: txn_payload);
  //     if (responseTxn.statusCode != 200) {
  //       print('error /txn/sheets/txn');
  //       return null;
  //     }
  //     List<int> responseTxnBytes = responseTxn.bodyBytes;
  //     String sTxn = bytesToHexStr(responseTxnBytes);
  //     print('发送txn_payload接收到数据${sTxn}---${sTxn.length}');
  //     MakeSheetResult makeSheetReusult = getTxnHash(responseTxnBytes);
  //     return makeSheetReusult;

  //     //根据生成的交易哈希可以作查询
  //     // bool isQuery = true;
  //     // if (txnHash != '') {
  //     //   while (isQuery) {
  //     //     sleep(Duration(seconds: 10));
  //     //     String url_txnhash =
  //     //         WEB_SERVER_ADDR + '/txn/sheets/state?hash=' + txnHash;
  //     //     var response_txnhash = await http.get(url_txnhash);
  //     //     if (response_txnhash.statusCode == 200) {
  //     //       QueryTxnHashResult queryTxnHashResult = queryTran(response_txnhash);
  //     //       if (queryTxnHashResult.status == 1) {
  //     //         //交易成功
  //     //         var msg = queryTxnHashResult.successInfo;
  //     //         if (msg.confirm >= 1) {
  //     //           print('[${DateTime.now()}] 交易成功');
  //     //           isQuery = false;
  //     //           // return msg;
  //     //         }
  //     //       }
  //     //     } else {
  //     //       print('Error: request failed, code=${response_txnhash.statusCode}');
  //     //     }
  //     //   }
  //     // }
  //   }
  // }
}

Future<QueryTxnHashResult> getQueryTxnHashResult(String txnHash) async {
  String utl = WEB_SERVER_ADDR + '/txn/sheets/state?hash=' + txnHash;
  var res = await http.get(utl);

  String command = getCommandStrFromBytes(res.bodyBytes);
  QueryTxnHashResult queryTxnHashResult;
  if (command == UdpReject.command) {
    UdpReject reject = parseUdpReject(res.bodyBytes);
    if (reject == null) return null;
    String sErr = reject.message;
    if (sErr == 'in pending state') {
      print('[${DateTime.now()}] Transaction state: pending');
      queryTxnHashResult = QueryTxnHashResult(
          stateInfo: S_PENDING, successInfo: null, status: TXN_PENDING);
      return queryTxnHashResult;
    } else {
      print('Error:$sErr');
      queryTxnHashResult = QueryTxnHashResult(
          stateInfo: '$sErr', successInfo: null, status: TXN_ERROR);
    }
  } else if (command == UdpConfirm.command) {
    UdpConfirm confirm = parseUdpConfirm(res.bodyBytes);
    if (confirm == null) return null;
    var hi = confirm.arg & 0xffffffff;
    var num = (confirm.arg >> 32) & 0xffff;
    var idx = (confirm.arg >> 48) & 0xffff;
    TxnSuccessInfo txnSuccessInfo =
        TxnSuccessInfo(confirm: num, height: hi, idx: idx);
    print(
        '[${DateTime.now()}] Transaction state: confirm=$num,hi=$hi,idx=$idx');
    queryTxnHashResult = QueryTxnHashResult(
        stateInfo: 'finish', successInfo: txnSuccessInfo, status: TXN_SUCCESS);
    return queryTxnHashResult;
  }
}

MakeSheetResult getTxnHash(responseTxnBytes) {
  String command = getCommandStrFromBytes(responseTxnBytes);
// List<int> txn_response_payload = response_txn_bytes.sublist(24);
  if (command == UdpReject.command) {
    UdpReject msg3 = parseUdpReject(responseTxnBytes);
    print('Error:${msg3.message}');
  } else if (command == UdpConfirm.command) {
    UdpConfirm msg3 = parseUdpConfirm(responseTxnBytes);
    if (msg3.hash == bytesToHexStr(hash_)) {
      state_info[2] = 'submited';
      sn = orgSheet.sequence;
      // if (sn！=null) {
      List info = submitInfo(sn);
      if (info == null) return null;
      var state = info[2];
      var txnHash = bytesToHexStr(info[3]);
      String lastUocks = bytesToHexStr(info[4][0]);
      if (state == 'submited' && txnHash != null) {
        String sDesc = '\nTransaction state:' + state;
        if (lastUocks != '') {
          sDesc += ',last uock: ' + lastUocks;
          print(sDesc);
          print('[${DateTime.now()}] Transaction hash:${txnHash}');
        }
        // }
        // return txn_hash;
        return MakeSheetResult(txnHash: txnHash, lastUock: lastUocks);
      }
    }
  }
}

List submitInfo(sn) {
// var state_info = [orgsheetMsg.sequence, txn, 'requested', hash_, orgsheetMsg.last_uocks];
  for (var i = 0; i < _wait_submit.length; i++) {
    List info = _wait_submit[i];
    if (info[0] == sn) {
      return info;
    }
  }
}

MakeSheet prepare_txn1_(pay_to, ext_in, submit, scan_count, min_utxo, max_utxo,
    sort_flag, from_uocks) {
  sequence += 1;
  List<PayFrom> pay_from = List<PayFrom>();
  PayFrom pay_from1 = PayFrom(
    value: 0,
    address: '13TtvKn5cwNhdxfXSbz1MewRnTEPB534rudq41LnRP1T9A4TJmjAKhJ',
  );
  pay_from.add(pay_from1);

  List<PayTo> payTo = List<PayTo>();
  PayTo payTo1 = PayTo(
    value: 1000000, //每次0.01测试
    address: '1118hfRMRrJMgSCoV9ztyPcjcgcMZ1zThvqRDLUw3xCYkZwwTAbJ5o',
  );
  payTo.add(payTo1);

  MakeSheet sheet = MakeSheet(
      vcn: 56026,
      sequence: sequence,
      pay_from: pay_from,
      pay_to: payTo,
      scan_count: scan_count,
      min_utxo: min_utxo,
      max_utxo: max_utxo,
      sort_flag: sort_flag,
      last_uocks: [0]);
  return sheet;
}

Uint8List decode_check(v) {
  Uint8List a = bs58check.base58.decode(v);
  Uint8List ret = a.sublist(0, a.length - 4);
  Uint8List check = a.sublist(a.length - 4);
  var checksum = sha256.convert(sha256.convert(ret).bytes).bytes.sublist(0, 4);
  if (checksum.toString() == check.toString()) {
    return ret;
  } else {
    return null;
  }
}

List<int> CHR(int value) {
  var w = ByteDataWriter();
  w.writeUint8(value);
  return w.toBytes();
}

// String get_reject_msg_(UdpReject msg){

//     var sErr = msg.message;
//     return sErr or 'Meet unknown error'
// }
