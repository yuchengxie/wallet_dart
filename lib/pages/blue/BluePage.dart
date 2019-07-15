import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nbc_wallet/api/provider/stateModel.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../api/bluetooth/blueservice.dart';

TextEditingController bleNameController;
TextEditingController pinCodeController;

class BluePage extends StatefulWidget {
  BluePage({Key key}) : super(key: key);

  _BluePageState createState() => _BluePageState();
}

class _BluePageState extends State<BluePage> {
  String _connectState;

  Future<void> _connectBlueTooth(String a, String b) async {
    String connectState = '';
    try {
      final String s =
          await BlueToothService.methodChannel.invokeMethod('connectBlueTooth', [a, b]);
      this._showToast("connectBlueTooth返回$s", duration: 3, gravity: Toast.TOP);
    } on PlatformException {
      connectState = 'bluetooth connect error';
    }
    setState(() {
      this._connectState = connectState;
    });
  }

  Future<void> _disConnectBlueTooth() async {
    String connectState = '';
    try {
      final int result =
          await BlueToothService.methodChannel.invokeMethod('disConnectBlueTooth');
      connectState = '连接结果:$result';
    } on PlatformException {
      connectState = 'bluetooth connect error';
    }
    setState(() {
      this._connectState = connectState;
    });
  }

  Future<void> _selectApp(String appSelectID) async {
    try {
      String s = await BlueToothService.methodChannel.invokeMethod('selectApp', [appSelectID]);
      this._showToast("$s", duration: 3, gravity: Toast.TOP);
    } on PlatformException {}
  }

  Future<void> _verifPIN(String pincode) async {
    try {
      String s = await BlueToothService.methodChannel.invokeMethod('verifPIN', [pincode]);
      print('接收到返回s:$s');
      this._showToast("$s", duration: 3, gravity: Toast.TOP);
    } on PlatformException {}
  }

  Future<void> _sign(String payload) async {
    try {
      String s = await BlueToothService.methodChannel.invokeMethod('sign', [payload]);
    } on PlatformException {}
  }

  Future<void> _verifySign(String signStr) async {
    try {
      String s = await BlueToothService.methodChannel.invokeMethod('verifySign', signStr);
    } on PlatformException {}
  }
  
  void _showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  void initState() {
    super.initState();
    bleNameController = TextEditingController();
    pinCodeController = TextEditingController();
    bleNameController.text = "BLESIM111111";
    pinCodeController.text = "123456";
    this._connectState = '请连接蓝牙';
    print('state:${this._connectState}');
    BlueToothService.eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  _onEvent(Object event) {
    setState(() {
      _connectState = '$event';
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
        title: Text('蓝牙SIM'),
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
              height: 15,
            ),
            Text(
              this._connectState,
              style: TextStyle(
                color: Colors.cyan,
              ),
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
            MOutlineButton(
              title: "验证PIN码",
              onPressed: () {
                this._verifPIN(pinCode);
              },
            ),
            MOutlineButton(
              title: "签名",
              onPressed: () {
                this._sign("123");
              },
            )
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
