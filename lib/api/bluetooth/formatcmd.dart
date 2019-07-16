
// const String CMD_PUB_ADDR='80220200 02 0000';
// const String CMD_PUB_KEY='80220000 00';
// const String CMD_PUB_KEY_HASH='80220100 00';
const String CMD_PUB_ADDR='80220200020000';
const String CMD_PUB_KEY='8022000000';
const String CMD_PUB_KEY_HASH='8022010000';

String formatPinCode(String pinCode) {
  //example 0020000003000000
  return '00200000' + '0' + '${(pinCode.length) ~/ 2}' + pinCode;
}

String formatPayloadToSign(String pinCode, String payload) {
  // '8021006023000000'+payload
  int pinLen = pinCode.length ~/ 2;
  String s1 = (pinLen << 5).toRadixString(16);
  String s2 = (pinLen + 32).toRadixString(16);
  return '802100' + s1 + s2 + pinCode + payload;
}

main() {
  String s = formatPayloadToSign('000000', 'abc123');
  print(s);
}
