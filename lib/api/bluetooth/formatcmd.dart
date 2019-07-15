String formatPinCode(String pinCode) {
  // 0020000003000000
  return '00200000' + '0' + '${(pinCode.length) ~/ 2}' + pinCode;
}

main() {
  String s = formatPinCode('000000');
  print(s);
}
