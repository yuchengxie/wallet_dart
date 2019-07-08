import '../utils/utils.dart';
import 'package:buffer/buffer.dart';
import './opcodes.dart';

var opcode;
var value;
var verify;
var bytes_;
var OP_LITERAL = 0x1ff;
var _expand_verify;

var _Verify = {
  0x88: OP_EQUAL,
  0x9d: OP_NUMEQUAL,
  0xad: OP_CHECKSIG,
  0xaf: OP_CHECKMULTISIG
};

String process(String pk_script) {
  var _tokens = [];
  List<int> script = hexStrToBytes(pk_script);
  while (script.length > 0) {
    opcode = ORD(script.sublist(0, 1));
    bytes_ = script.sublist(0, 1);
    script=script.sublist(1);
    value = null;
    verify = false;

    if (opcode == OP_0) {
      value = 0;
      opcode = OP_LITERAL;
    } else if (opcode > 1 && opcode <= 78) {
      int length = opcode;
      if (opcode >= OP_PUSHDATA1 && opcode <= OP_PUSHDATA4) {
        // var iTmp = opcode - OP_PUSHDATA1;
        // var op_length = [1, 2, 4][iTmp];
        //todo
      }
      var sTmp = script.sublist(0, length);
      value = bytesToHexStr(sTmp);
      var newList = new List.from(bytes_)..addAll(sTmp);
      bytes_ = newList;
      script = script.sublist(length);
      opcode = OP_LITERAL;
    } else if (opcode == OP_LITERAL) {
      opcode = OP_LITERAL;
      value = -1;
    } else if (opcode == OP_TRUE) {
      opcode = OP_LITERAL;
      value = 1;
    } else if (opcode >= OP_1 && opcode <= OP_16) {
      opcode = OP_LITERAL;
      // value = 0;
    } else if (_expand_verify != null && _Verify[opcode] != null) {
      opcode = _Verify[opcode];
      verify = true;
    }
    _tokens.add([opcode, bytes_, value]);
    if (verify) {
      // _tokens.add(OP_VERIFY, '0', null);
    }
  }
  var output = [];
  for (var t in _tokens) {
    // var t = k1;
    if (t[0] == OP_LITERAL) {
      output.add(t[2]);
    } else {
      if (t[1]!=null) {
        var s = get_opcode_name(t[0]);
        output.add(s);
      }
    }
  }
  var s = '';
  for (var i = 0; i < output.length; i++) {
    if (i < output.length - 1) {
      s += output[i] + ' ';
    } else {
      s += output[i];
    }
  }
  return s;
}

int ORD(ch) {
  ByteDataReader reader = ByteDataReader();
  reader.add(ch);
  int v = reader.readUint8();
  return v;
}
