class TeeWallet {
  final String pub_key;
  final String pub_hash;
  final int vcn;
  final String coin_type;
  final String pub_addr;
  final String pin_code;

  TeeWallet(this.pub_key, this.pub_hash, this.vcn, this.coin_type,
      this.pub_addr, this.pin_code);

  TeeWallet.fromJson(Map<String, dynamic> json)
      : pub_key = json['pub_key'],
        pub_hash = json['pub_hash'],
        vcn = json['vcn'],
        coin_type = json['coin_type'],
        pub_addr = json['pub_addr'],
        pin_code = json['pin_code'];
}

class TeeSign {
  String msg;
  int status;
  TeeSign({this.msg, this.status});
  TeeSign.fromJson(Map<String, dynamic> json)
      : msg = json['msg'],
        status = json['status'];
}

class TeeVerifySign {
  String msg;
  int status;
  TeeVerifySign({this.msg, this.status});
  TeeVerifySign.fromJson(Map<String, dynamic> json)
      : msg = json['msg'],
        status = json['status'];
}

class QueryTxnHashResult {
  // String msg;
  TxnSuccessInfo successInfo;
  String stateInfo;
  int status;
  QueryTxnHashResult({this.successInfo, this.stateInfo, this.status});
  QueryTxnHashResult.fromJson(Map<String, dynamic> json)
      : successInfo = json['successInfo'],
        stateInfo = json['stateInfo'],
        status = json['status'];
}

class TxnSuccessInfo {
  int height;
  int confirm;
  int idx;
  TxnSuccessInfo({this.height, this.confirm, this.idx});
  TxnSuccessInfo.fromJson(Map<String, dynamic> json)
      : height = json['height'],
        confirm = json['confirm'],
        idx = json['idx'];

  Map toJson() {
    Map map = new Map();
    map["height"] = this.height;
    map["confirm"] = this.confirm;
    map["idx"] = this.idx;
    return map;
  }
}

class MakeSheetResult {
  String txnHash;
  String lastUock;
  MakeSheetResult({this.txnHash,this.lastUock});
}
