class PseudoWallet {
  String pubKey;
  String pubHash;
  String vcn;
  String coinType;
  String pubAddr;
  String pinCode = '000000';

  PseudoWallet(
      {this.pubKey,
      this.pubHash,
      this.vcn,
      this.coinType,
      this.pubAddr,
      this.pinCode});
}
