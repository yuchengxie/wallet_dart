import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import '../utils/utils.dart';
import 'package:crypto/crypto.dart';
import '../model/message.dart';

ByteDataWriter _write;
final _magic = [0xf9, 0x6e, 0x62, 0x74];
/*
 * 创建交易表单二进制组包
 */
List<int> getTxnPayload(Transaction txn) {
  _write = ByteDataWriter();
  _write.writeUint32(txn.version);
  _writeTxIns(txn.tx_in);
  _writeTxOuts(txn.tx_out);
  _write.writeUint32(txn.lock_time);
  _writeVarString(txn.sig_raw);
  return _write.toBytes();
}

/*
 * 发送表单二进制组包 
 */
List<int> makeSheetpayload(MakeSheet msg) {
  _write = ByteDataWriter();
  _write.writeUint16(msg.vcn);
  _write.writeUint32(msg.sequence);
  _writepayfrom(msg.pay_from);
  _writepayto(msg.pay_to);
  _write.writeUint16(msg.scan_count);
  _write.writeUint64(msg.min_utxo);
  _write.writeUint64(msg.max_utxo);
  _write.writeUint32(msg.sort_flag);
  _writelastuocks(msg.last_uocks);
  return _write.toBytes();
}

List<int> flexTxnPayload(FlexTxn msg) {
  _write = ByteDataWriter();
  _write.writeUint32(msg.version);
  _writeTxIns(msg.tx_in);
  _writeTxOuts(msg.tx_out);
  _write.writeUint32(msg.lock_time);
  return _write.toBytes();
}

Uint8List script_payload(subscript, txns_ver, List<TxIn> txns_in,
    List<TxOut> txns_out, lock_time, input_index, hash_type) {
  var tx_outs = txns_out;
  var tx_ins = [];
  if ((hash_type & 0x1F) == 0x01) {
    for (var index = 0; index < txns_in.length; index++) {
      var tx_in = txns_in[index];
      String script = '';
      if (index == input_index) {
        script = subscript;
      }
      print('>>> script:${script}---${script.length}');
      tx_in.sig_script = script;
      tx_ins.add(tx_in);
    }
  }
  if (tx_ins == null || tx_outs == null) {
    throw 'tx_ins txouts can not be null';
  }
  var tx_copy = FlexTxn(
      version: txns_ver, tx_in: txns_in, tx_out: tx_outs, lock_time: lock_time);
  List<int> payload = flexTxnPayload(tx_copy);
  var w = new ByteDataWriter();
  w.write(payload);
  w.writeUint32(hash_type);
  return w.toBytes();
}

List<int> getPayload(List<int> data) {
  if (data.sublist(0, 4).toString() != _magic.toString()) {
    print('data error');
    return null;
  }
  final payload = data.sublist(24);
  final checksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  if (data.sublist(20, 24).toString() != checksum.toString()) {
    print('checksum error');
    return null;
  }
  return payload;
}

List<int> wholePayload(List<int> payload, String command) {
  ByteDataWriter w = ByteDataWriter();
  //0-4 magic
  w.write(_magic);
  //4-16
  final _command = strToBytes(command, length: 12);
  w.write(_command);
  //16-20
  w.writeUint32(payload.length);
  //20-24
  final checksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  w.write(checksum);
  w.write(payload);
  return w.toBytes();
}

void _writelastuocks(List<int> msg) {
  _write.writeUint8(msg.length);
  for (var i = 0; i < msg.length; i++) {
    _write.writeUint64(msg[i]);
  }
}

void _writepayfrom(List<PayFrom> msg) {
  int len = msg.length;
  _write.writeUint8(len);
  for (int i = 0; i < len; i++) {
    PayFrom p = msg[i];
    String address = p.address;
    _write.writeUint64(p.value);
    _write.writeUint8(address.length);
    _write.write(strToBytes(address));
  }
}

void _writepayto(List<PayTo> msg) {
  int len = msg.length;
  _write.writeUint8(len);
  for (int i = 0; i < len; i++) {
    PayTo p = msg[i];
    String address = p.address;
    _write.writeUint64(p.value);
    _write.writeUint8(address.length);
    _write.write(strToBytes(address));
  }
}

void _writeTxIns(List<TxIn> tx_ins) {
  int len = tx_ins.length;
  _write.writeUint8(len);
  for (int i = 0; i < len; i++) {
    TxIn txn = tx_ins[i];
    //prev_output
    OutPoint prev_output = txn.prev_output;
    //固定长度不用计算长度
    List<int> hash = hexStrToBytes(prev_output.hash);
    _write.write(hash);
    _write.writeUint32(prev_output.index);
    //sig_script
    _writeVarString(txn.sig_script);
    //sequence
    _write.writeUint32(txn.sequence);
  }
}

void _writeTxOuts(List<TxOut> tx_outs) {
  int len = tx_outs.length;
  _write.writeUint8(len);
  for (int i = 0; i < len; i++) {
    TxOut tx_out = tx_outs[i];
    _write.writeUint64(tx_out.value);
    _writeVarString(tx_out.pk_script);
  }
}

void _writeVarString(String hexstr) {
  List<int> bytes = hexStrToBytes(hexstr);
  int len = bytes.length;
  _write.writeUint8(len);
  _write.write(bytes);
}
