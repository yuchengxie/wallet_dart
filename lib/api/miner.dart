import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
// import 'package:buffer/buffer.dart';
import './utils/bytes.dart';
import '../api/utils/utils.dart';

var SELECT = '00A404000ED196300077130010000000020101';
var cmd_pubAddr = '80220200020000';
var cmd_pubkey = '8022000000';
var cmd_pubkeyHash = '8022010000';
var _heartTimer;

var mine_hostname = 'user1-node.nb-chain.net';
var mine_port = 30302;
var pseudoWallet;
List<InternetAddress> addressArray;

void main() async {
  // addressArray = await InternetAddress.lookup(mine_hostname);
  // RawDatagramSocket datagramSocket =
  //     await RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0);
  // PoetClient poetClient = PoetClient(socket: datagramSocket);
  // String s =
  //     'f96e6274706f65747461736b000000000c000000ee9b92e3000000000000000000000000';
  // poetClient.sendMessage(s);
  // print('Sending msg: $s\n');
}

class PoetClient {
  int POET_POOL_HEARTBEAT = 5 * 1000;
  List PEER_ADDR_ = [];
  bool _active = false;
  var miners;
  String name;
  int _link_no;
  var _coin;
  var _last_peer_addr;
  var _recv_buffer;
  var _last_rx_time;
  var _last_pong_time;
  int _reject_count;
  int _last_taskid;
  var _time_taskid;
  var _compete_src = [];
  RawDatagramSocket socket;
  // = RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0);
  var set_peer;

  PoetClient({this.socket});

  StreamSubscription socketListen;
  void start() {
    this._active = true;
    _heartTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (this._active) {
        try {
          this._heatbeat();
        } catch (error) {
          print('heartbeat error:$error');
          // socketListen.cancel();
        }
      }
    });
  }

  _heatbeat() {
    if (this.PEER_ADDR_.length == 0) return;
    var now = timest(); //单位毫秒，10位时间戳
    if ((now - this._time_taskid) > 1800) {
      this._time_taskid = 0;
    }
    if (this._reject_count > 120) {
      this._reject_count = 0;
      this._last_taskid = 0;
    }
    if ((now - this._last_rx_time) > 1800 && this._last_peer_addr) {
      try {
        // var sock =
        // RawDatagramSocket.bind(InternetAddress.LOOPBACK_IP_V4, mine_port);
        // this.socket.clo
        _set_peer(this._last_peer_addr);
      } catch (error) {
        print('renew socket err:$error');
      }
    }

    var compete_src = this._compete_src;
    if (compete_src.length == 6) {
      var miners = this.miners;
      var sn = compete_src[0];
      var block_hash = compete_src[1];
      var bits = compete_src[2];
      var txn_num = compete_src[3];
      var link_no = compete_src[4];
      var hi = compete_src[5];
      TeeMiner succ_miner;
      String succ_sig = '';
      for (TeeMiner miner in miners) {
        miner
            .check_elapsed(block_hash, bits, txn_num, now, '00', hi)
            .then((sig) {
          print('sig: $sig');
          if (sig != "") {
            succ_miner = miner;
            succ_sig = sig;
          }
          if (succ_miner != null) {
            this._compete_src = [];
            var msg = PoetResult(
                link_no: link_no,
                curr_id: sn,
                miner: succ_miner.pub_keyhash,
                sig_tee: succ_sig);
            //组包解包
            print('success mining');
          }
        });
      }

      if (now >= (this._last_rx_time + this.POET_POOL_HEARTBEAT / 1000)) {
        var msg = GetPoetTask(
            link_no: this._link_no,
            curr_id: this._last_taskid,
            timestamp: this._time_taskid);
        // var buf = new BytesBuffer();
        //数据组包解包
        var command = 'poettask';
        var msg_buf;
        // this.s
      }
    }

    // this.socket.then(socket){

    // };
  }

  sendMessage(String msg) {
    this.socket.send(hexStrToBytes(msg), addressArray.first, mine_port);
    socketListen = this.socket.listen((RawSocketEvent evt) {
      if (evt == RawSocketEvent.READ) {
        Datagram packet = socket.receive();
        String data = bytesToHexStr(packet.data);
        print('receive data:$data');
        // socketListen.cancel();
      }
    });
  }

  socketlisten() {}

  // this.socket
}

void _set_peer(peer_addr) {
  //todo
}

class TeeMiner {
  int SUCC_BLOCKS_MAX = 256;
  List succ_blocks = [];
  final String pub_keyhash;

  TeeMiner(this.pub_keyhash);

  Future<String> check_elapsed(
      String block_hash, bits, txn_num, curr_tm, sig_flag, hi) async {
    if (!curr_tm) curr_tm = timest();
    try {
      // ByteDataWriter w1 = ByteDataWriter();
      String sCmd = '8023' + sig_flag + '00';
      List<int> sCmdBytes = hexStrToBytes(sCmd);

      List<int> blockhashbytes = hexStrToBytes(block_hash);
      List<int> pack1 = pack('<II', [bits, txn_num]);
      List<int> sBlockInfo = List.from(blockhashbytes)..addAll(pack1);

      List<int> pack2 = null;
      // pack('<IB', [curr_tm, .length, w1.toBytes()]);
      List<int> sData = List.from(pack2)..addAll(sBlockInfo);

      List<int> sCmdBytes_t = List.from(sCmdBytes)..addAll(sData);

      var sCmdBytes_t_str = bytesToHexStr(sCmdBytes_t);
      await transmit(sCmdBytes_t_str).then((res) {
        if (res.length > 128) {
          this.succ_blocks.add([curr_tm, hi]);
          if (this.succ_blocks.length > this.SUCC_BLOCKS_MAX) {
            // this.succ_blocks.splice(this.SUCC_BLOCKS_MAX, 1);
            this.succ_blocks.remove(this.SUCC_BLOCKS_MAX);
          }
          // return List.from(hexStrToBytes(res))..add(hexStrToBytes(sig_flag));
          return 'hahh';
        } else {
          // return bh.hexStrToBuffer('00');
          return '';
        }
      });
      // return transmit(sCmd).then(res => {
      //       if (res.data.length > 128) {
      //           this.succ_blocks.push([curr_tm, hi]);
      //           if (this.succ_blocks.length > this.SUCC_BLOCKS_MAX) {
      //               this.succ_blocks.splice(this.SUCC_BLOCKS_MAX, 1);
      //           }
      //           return Buffer.concat([bh.hexStrToBuffer(res.buffer), bh.hexStrToBuffer(sig_flag)]);
      //       } else {
      //           // return bh.hexStrToBuffer('00');
      //           return '';
      //       }
      //   });
    } catch (e) {}
  }
}

class PoetResult {
  var link_no;
  var curr_id;
  var miner;
  var sig_tee;
  PoetResult({this.link_no, this.curr_id, this.miner, this.sig_tee});
}

class GetPoetTask {
  var link_no;
  var curr_id;
  var timestamp;
  GetPoetTask({this.link_no, this.curr_id, this.timestamp});
}

//模拟蓝牙
Future<String> transmit(String cmd) async {
  return '123';
}

List<int> pack(String str, List args) {
  if (str.length <= 1) {
    print('pack data invalid');
    return null;
  }
  if (str.length - 1 != args.length) {
    print('pack data invalid');
  }
  ByteDataWriter writer = ByteDataWriter();
  if (str[0] == '<') {
    for (int i = 0; i < args.length; i++) {
      var r = str[i + 1];
      if (r == 'I') {
        writer.writeUint8(args[i]);
      }
      if (r == 'B') {
        writer.writeUint8(args[i]);
      }
      if (r == 'H') {
        writer.writeUint16(args[i]);
      }
    }
  } else {
    //大端todo
  }
  return writer.toBytes();
}

int timest() {
  return int.parse(DateTime.now()
      .millisecondsSinceEpoch
      .toString()
      .substring(0, 10)); //单位毫秒，10位时间戳
}
