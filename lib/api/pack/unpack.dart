import 'package:buffer/buffer.dart';
import '../utils/utils.dart';
import '../model/message.dart';
import 'package:crypto/crypto.dart';

ByteDataReader _reader;

dynamic parse(List<int> bytes, String command) {
  //1.验证接收来的数据的checksum
  if (!isChecksum(bytes)) {
    return null;
  }
  //2.根据不同的command,作对应的解析
  List<int> payload = bytes.sublist(24);
  print('command:${command}');
  if (command == UdpReject.command) {
    return parseUdpReject(payload);
  } else if (command == UdpConfirm.command) {
    return parseUdpConfirm(payload);
  } else if (command == OrgSheet.command) {
    return parseOrgSheet(payload);
  }
}

//bytes转换成一个对象
OrgSheet parseOrgSheet(List<int> bytes) {
  if (!isChecksum(bytes)) {
    return null;
  }
  _reader = ByteDataReader();
  _reader.add(bytes.sublist(24));
  int sequence = _reader.readUint32();
  List<VarStrList> pks_out = _readPksout();
  // List<int> last_uocks = _readLastUocks();
  List<List<int>> last_uocks = _readLastUocks();
  int version = _reader.readUint32();
  List<TxIn> tx_in = _readTxIns();
  List<TxOut> tx_out = _readTxOuts();
  int lock_time = _reader.readUint32();
  String signature = _readVarString();

  OrgSheet _orgSheet = OrgSheet(
      sequence: sequence,
      pks_out: pks_out,
      last_uocks: last_uocks,
      version: version,
      tx_in: tx_in,
      tx_out: tx_out,
      lock_time: lock_time,
      signature: signature);
  return _orgSheet;
}

List<TxIn> _readTxIns() {
  List<TxIn> tx_ins = List<TxIn>();
  int len1 = _reader.readUint8();
  for (var i = 0; i < len1; i++) {
    //1.prev_output
    String hash = bytesToHexStr(_reader.read(32));
    int index = _reader.readUint32();
    OutPoint prev_output = OutPoint(hash: hash, index: index);
    //2.sig_script
    String sig_script = _readVarString();
    //3.sequence
    int sequence = _reader.readUint32();
    TxIn txIn = TxIn(
        prev_output: prev_output, sig_script: sig_script, sequence: sequence);
    tx_ins.add(txIn);
  }
  return tx_ins;
}

List<TxOut> _readTxOuts() {
  List<TxOut> tx_outs = List<TxOut>();
  int len1 = _reader.readUint8();
  for (var i = 0; i < len1; i++) {
    int value = _reader.readUint64();
    String pk_script = _readVarString();
    TxOut txOut = TxOut(value: value, pk_script: pk_script);
    tx_outs.add(txOut);
  }
  return tx_outs;
}

String _readVarString() {
  int len = _reader.readUint8();
  if (len == 0) {
    return '';
  }
  return bytesToHexStr(_reader.read(len));
}

List<List<int>> _readLastUocks() {
  // List<int> last_uocks = List<int>();
  List<List<int>> last_uocks = List<List<int>>();
  int len = _reader.readUint8();
  for (var i = 0; i < len; i++) {
    // int v = _reader.readUint64();
    // String v=_reader.read(8);
    List<int> l = _reader.read(8);
    // String s = bytesToHexStr(l);
    last_uocks.add(l);
  }
  return last_uocks;
}

List<VarStrList> _readPksout() {
  List<VarStrList> pksout = List<VarStrList>();

  int len1 = _reader.readUint8();
  int len2 = _reader.readUint8();
  for (int i = 0; i < len1; i++) {
    VarStrList varlist = VarStrList();
    varlist.items = List<String>();
    for (int i = 0; i < len2; i++) {
      int len3 = _reader.readUint8();
      List<int> item = _reader.read(len3);
      final str = bytesToHexStr(item);
      varlist.items.add(str);
    }
    pksout.add(varlist);
  }
  return pksout;
}

UdpReject parseUdpReject(List<int> bytes) {
  if (!isChecksum(bytes)) {
    return null;
  }
  _reader = ByteDataReader();
  _reader.add(bytes.sublist(24));
  int sequence = _reader.readUint32();
  String messageHex = _readVarString();
  //转latin1字符
  List<int> messagebytes = hexStrToBytes(messageHex);
  String message = bytesToStr(messagebytes);
  String source = _readVarString();
  UdpReject udpReject =
      UdpReject(sequence: sequence, message: message, source: source);
  return udpReject;
}

UdpConfirm parseUdpConfirm(List<int> bytes) {
  if (!isChecksum(bytes)) {
    return null;
  }
  _reader = ByteDataReader();
  _reader.add(bytes.sublist(24));
  String hash = bytesToHexStr(_reader.read(32));
  int arg = _reader.readUint64();
  UdpConfirm udpConfirm = UdpConfirm(hash: hash, arg: arg);
  return udpConfirm;
}

bool isChecksum(List<int> bytes) {
  if (bytes.length < 24) {
    print('data error');
    return false;
  }
  List<int> check = bytes.sublist(20, 24);
  List<int> payload = bytes.sublist(24);
  List<int> checksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  if (checksum.toString() != check.toString()) {
    print('bad checksum');
    return false;
  }
  return true;
}

//专用获取命令字符串
String getCommandStrFromBytes(List<int> bytes) {
  List<int> m = trimCommand(bytes.sublist(4, 16));
  return bytesToStr(m);
}

List<int> trimCommand(List<int> bytes) {
  if (bytes.length != 12) throw 'err length';
  int index = bytes.indexOf(0);
  var tempList = new List<int>.from(bytes);
  tempList..removeRange(index, tempList.length);
  return tempList;
}
