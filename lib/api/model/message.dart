class PayFrom {
  int value;
  String address;
  PayFrom({this.value, this.address});
}

class PayTo {
  int value;
  String address;
  PayTo({this.value, this.address});
}

class MakeSheet {
  int vcn;
  int sequence;
  List<PayFrom> pay_from;
  List<PayTo> pay_to;
  int scan_count;
  int min_utxo;
  int max_utxo;
  int sort_flag;
  List<int> last_uocks;
  MakeSheet(
      {this.vcn,
      this.sequence,
      this.pay_from,
      this.pay_to,
      this.scan_count,
      this.min_utxo,
      this.max_utxo,
      this.sort_flag,
      this.last_uocks});
}

class OrgSheet {
  static String command = 'orgsheet';
  int sequence;
  List<VarStrList> pks_out;
  // List<int> last_uocks;
  List<List<int>> last_uocks;
  int version;
  List<TxIn> tx_in;
  List<TxOut> tx_out;
  int lock_time;
  String signature;
  OrgSheet(
      {this.sequence,
      this.pks_out,
      this.last_uocks,
      this.version,
      this.tx_in,
      this.tx_out,
      this.lock_time,
      this.signature});
}

class OutPoint {
  String hash;
  int index;
  OutPoint({this.hash, this.index});
}

class TxIn {
  OutPoint prev_output;
  String sig_script;
  int sequence;
  TxIn({this.prev_output, this.sig_script, this.sequence});
}

class TxOut {
  int value;
  String pk_script;
  TxOut({this.value, this.pk_script});
}

class VarStrList {
  List<String> items;
  VarStrList({this.items});
}

class FlexTxn {
  int version;
  List<TxIn> tx_in;
  List<TxOut> tx_out;
  int lock_time;
  FlexTxn({this.version, this.tx_in, this.tx_out, this.lock_time});
}

class Transaction {
  String command = 'tx';
  int version;
  List<TxIn> tx_in;
  List<TxOut> tx_out;
  int lock_time;
  String sig_raw;
  Transaction(
      {this.version, this.tx_in, this.tx_out, this.lock_time, this.sig_raw});
}

class UdpConfirm {
  static String command = 'confirm';
  String hash;
  int arg;
  UdpConfirm({this.hash, this.arg});
}

class UdpReject {
  static String command = 'reject';
  int sequence;
  String message;
  String source;
  UdpReject({this.sequence, this.message, this.source});
}
