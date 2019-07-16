import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nbc_wallet/api/provider/stateModel.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../api/bluetooth/blueservice.dart';

TextEditingController bleNameController;
TextEditingController pinCodeController;
TextEditingController pinCodeVerifyController;

const String blueNotConnected = "蓝牙未连接";

class BluePage extends StatefulWidget {
  BluePage({Key key}) : super(key: key);

  _BluePageState createState() => _BluePageState();
}

class _BluePageState extends State<BluePage> {
  String _connectState;
  _connectBlueTooth(String bleName, String pinCode) async {
    await connectBlueTooth(bleName, pinCode);
  }

  _disConnectBlueTooth() async {
    disConnectBlueTooth();
    setState(() {
      this._connectState = '蓝牙断开';
    });
  }

  _selectApp(String appSelectID) async {
    String s = await selectApp(appSelectID);
    s = s == '1' ? '选择应用成功' : blueNotConnected;
    this._showToast("$s");
  }

  _verifPIN(String pinCode) async {
    String s = '';
    String res = await verifPIN(pinCode);
    print('_verifPIN res: $res');
    if (res == '0') {
      this._showToast(blueNotConnected);
      return;
    }
    if (res == '9000') {
      s = '密码验证成功';
    } else if (res.substring(0, 3) == '63c') {
      s = '密码不正确, 剩余输入次数: ' + res.substring(3);
    } else {
      s = '密码验证错误';
    }
    this._showToast("$s");
  }

  _sign(String readySignStr) async {
    String s = await sign('000000', 'abc123');
    print('_sign res: $s');
    if (s == "0") {
      this._showToast(blueNotConnected);
      return;
    }
    this._showToast("$s---${s.length}");
  }

  _getPubAddr() async {
    String s = await getPubAddr();
    if (s == "0") {
      this._showToast(blueNotConnected);
      return;
    }
    this._showToast("地址:$s");
  }

  _getPubKey() async {
    String s = await getPubKey();
    if (s == "0") {
      this._showToast(blueNotConnected);
      return;
    }
    this._showToast("pubkey:$s");
  }

  _getPubKeyHash() async {
    String s = await getPubKeyHash();
    if (s == "0") {
      this._showToast(blueNotConnected);
      return;
    }
    this._showToast("pubkeyhash:$s");
  }

  // Future<void> _verifySign(String signStr) async {
  //   try {
  //     String s = await methodChannel.invokeMethod('verifySign', signStr);
  //   } on PlatformException {}
  // }

  void _showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: 2, gravity: Toast.BOTTOM);
  }

  @override
  void initState() {
    super.initState();
    bleNameController = TextEditingController();
    pinCodeController = TextEditingController();
    pinCodeVerifyController = TextEditingController();
    bleNameController.text = "BLESIM111111";
    pinCodeController.text = "123456";
    pinCodeVerifyController.text = "000000";
    this._connectState = '蓝牙SIM卡';
    print('state:${this._connectState}');
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  _onEvent(Object event) {
    // print('event: $event');
    Map dic=event;
    print('event: $dic');
    gPseudoWallet.pubAddr=dic["pubAddr"];
    gPseudoWallet.pubKey=dic["pubKey"];
    gPseudoWallet.pubHash=dic["pubHash"];
    // print('event state: ${event['state']}');
    setState(() {
      _connectState = dic["state"] == '1' ? '蓝牙连接成功' : '蓝牙未连接';
    });
  }

  _onError(Object error) {
    setState(() {
      _connectState = '连接状态:unknow';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this._connectState),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: bleNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.bluetooth),
                hintText: '请输入蓝牙设备名称',
              ),
            ),
            TextField(
              controller: pinCodeController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.payment),
                hintText: '请输入pin码',
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MOutlineButton(
              title: '连接蓝牙',
              onPressed: () {
                this._connectBlueTooth(
                    bleNameController.text, pinCodeController.text);
              },
            ),
            SizedBox(
              height: 10,
            ),
            MOutlineButton(
              title: "断开蓝牙",
              onPressed: () {
                this._disConnectBlueTooth();
              },
            ),
            SizedBox(
              height: 25,
            ),
            MOutlineButton(
              title: "选择应用",
              onPressed: () {
                this._selectApp(appSelectID);
              },
            ),
            TextField(
              controller: pinCodeVerifyController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.pin_drop),
                hintText: '请输入要验证的PIN码',
              ),
            ),
            MOutlineButton(
              title: "验证PIN码",
              onPressed: () {
                this._verifPIN(pinCodeVerifyController.text.trim());
              },
            ),
            MOutlineButton(
              title: "签名",
              onPressed: () {
                this._sign("123");
              },
            ),
            MOutlineButton(
              title: "pubaddr",
              onPressed: () {
                this._getPubAddr();
              },
            ),
            MOutlineButton(
              title: "pubkey",
              onPressed: () {
                this._getPubKey();
              },
            ),
            MOutlineButton(
              title: "pubkeyhash",
              onPressed: () {
                this._getPubKeyHash();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MOutlineButton extends StatefulWidget {
  final String title;
  final onPressed;
  MOutlineButton({Key key, this.title, this.onPressed}) : super(key: key);
  _MOutlineButtonState createState() =>
      _MOutlineButtonState(this.title, this.onPressed);
}

class _MOutlineButtonState extends State<MOutlineButton> {
  final String title;
  final onPressed;
  _MOutlineButtonState(this.title, this.onPressed);
  @override
  Widget build(BuildContext context) {
    StateModel _stateModel = Provider.of<StateModel>(context);
    Color _color = _stateModel.walletTheme.brightness == Brightness.dark
        ? Colors.white
        : Colors.grey[600];
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlineButton(
              child: Text(this.title),
              highlightedBorderColor: Colors.cyan,
              borderSide: BorderSide(width: 1, color: _color),
              onPressed: this.onPressed,
            ),
          )
        ],
      ),
    );
  }
}
