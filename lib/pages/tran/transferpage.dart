import 'dart:async';
// import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:nbc_wallet/api/provider/stateModel.dart';
import 'package:nbc_wallet/api/transfer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

TextEditingController addrController = TextEditingController();
TextEditingController amountController = TextEditingController();
TextEditingController txnHashController = TextEditingController();
TextEditingController lastUockController = TextEditingController();
StateModel _stateModel;

class TransferPage extends StatefulWidget {
  TransferPage({Key key}) : super(key: key);

  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Future scan() async {
    // try {
    //   String barcode = await BarcodeScanner.scan();
    //   setState(() {
    //     // return this.barcode = barcode;
    //     print('barcode: $barcode');
    //     addrController.text=barcode;
    //     _stateModel.updateAddr(barcode);
    //   });
    // } on PlatformException catch (e) {
    //   if (e.code == BarcodeScanner.CameraAccessDenied) {
    //     print('barcode:null');
    //     setState(() {
    //       // return this.barcode = 'The user did not grant the camera permission!';
    //     });
    //   } else {
    //     print('barcode:null');
    //     setState(() {
    //       // return this.barcode = 'Unknown error: $e';
    //     });
    //   }
    // } on FormatException {
    //   // setState(() => this.barcode =
    //   //     'null (User returned using the "back"-button before scanning anything. Result)');
    // } catch (e) {
    //   // setState(() => this.barcode = 'Unknown error: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    _stateModel = Provider.of<StateModel>(context);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('NBC-转账'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                //扫描二维码
                scan();
              },
            )
          ],
        ),
        body: TransferComponent(),
      ),
    );
  }
}

class TransferComponent extends StatefulWidget {
  TransferComponent({Key key}) : super(key: key);

  _TransferComponentState createState() => _TransferComponentState();
}

class _TransferComponentState extends State<TransferComponent> {
  String _tranState = '';
  bool _isDisableButton = true;
  Timer _timer;
  bool _isProgerssVisable = true;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addrController.text = '${_stateModel.recvAddr}';
    amountController.text = '${_stateModel.amount}';
    txnHashController.text = '${_stateModel.txnHash}';
    lastUockController.text = '${_stateModel.lastUock}';

    loopQuery(String txnHash) {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
        _isDisableButton = true;
        return;
      }
      _tranState = '准备转帐';
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        getQueryTxnHashResult(txnHash).then((res) {
          if (res.status == 1) {
            //查询状态转账成功,可以停止计时器
            setState(() {
              _tranState = _tranState =
                  '区块高度: ${res.successInfo.height},确认区块: ${res.successInfo.confirm}';
              if (res.successInfo.confirm == 1) {
                _timer.cancel();
                _timer = null;
                _isProgerssVisable = true;
                _isDisableButton = true;
              }
            });
          } else {
            setState(() {
              _tranState = '${res.stateInfo}' == 'pending' ? '等待区块确认' : '';
            });
          }
        });
      });
    }

    _transferAction() {
      transfer('', '').then((res) {
        if (res != null) {
          _stateModel.updateTxnHash(res.txnHash);
          _stateModel.updateLastUock(res.lastUock);
          _isDisableButton = false;
          _isProgerssVisable = false;
          loopQuery(res.txnHash);
        }
      });
    }

    return Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            TextField(
              maxLength: 54,
              maxLines: 2,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    addrController.clear();
                    _stateModel.updateAddr('');
                    print('选择地址');
                    // showModalBottomSheet(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return Center(
                    //         // child: Text('123'),
                    //       );
                    //     });
                  },
                ),
                border: OutlineInputBorder(),
                labelText: '收款钱包地址',
              ),
              controller: addrController,
              onChanged: (value) {
                _stateModel.updateAddr(value);
              },
            ),

            SizedBox(
              height: 10,
            ),
            TextFieldOutLine(
              labelText: '转账金额',
              controller: amountController,
              changed: (value) {
                _stateModel.updateAddr(value);
              },
            ),
            TextFieldOutLine(
              labelText: '交易生成hash',
              maxLines: 2,
              controller: txnHashController,
              changed: (value) {
                _stateModel.updateTxnHash(value);
              },
            ),
            // TextFieldOutLine(
            //   labelText: '最后uock',
            //   maxLines: 1,
            //   controller: lastUockController,
            //   changed: (value) {
            //     _stateModel.updateLastUock(value);
            //   },
            // ),
            // Text(
            //   this._tranState,
            //   textAlign: TextAlign.start,
            //   style: TextStyle(fontSize: 15, color: Colors.grey),
            // ),
            SizedBox(
              height: 20,
            ),
            Offstage(
              offstage: _isProgerssVisable, //true隐藏false显示
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        this._tranState,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '区块确认 1/8',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      value: 0.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     IconButton(
            //       icon: Icon(Icons.navigate_next),
            //       iconSize: 25.0,
            //       color: Colors.grey,
            //       splashColor: Colors.transparent,
            //       tooltip: '123',
            //       onPressed: (){
            //         print('details');
            //       },
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('详情'),
                // SizedBox(width: 5,),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  iconSize: 12,
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.pushNamed(context, '/txnDetailsPage');
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 40,
                    child: RaisedButton(
                      color: Colors.cyan,
                      textColor: Colors.white,
                      child: Text('交 易'),
                      onPressed: _isDisableButton ? _transferAction : null,
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }
}

class TextFieldOutLine extends StatefulWidget {
  final String labelText;
  final int maxLines;
  Icon suffix;
  TextEditingController controller;
  String controllerText;
  final changed;

  TextFieldOutLine(
      {Key key,
      this.labelText = '',
      this.maxLines = 1,
      this.suffix,
      this.controllerText,
      this.controller,
      this.changed})
      : super(key: key);

  _TextFieldOutLineState createState() => _TextFieldOutLineState(
      labelText, maxLines, suffix, controllerText, controller, changed);
}

class _TextFieldOutLineState extends State<TextFieldOutLine> {
  // final TextEditingController controller;

  final labelText;
  final maxLines;
  Icon suffix;
  String controllerText;
  TextEditingController controller;
  final changed;

  _TextFieldOutLineState(this.labelText, this.maxLines, this.suffix,
      this.controllerText, this.controller, this.changed);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TextField(
            maxLines: this.maxLines,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15),
              border: OutlineInputBorder(),
              labelText: this.labelText,
              suffix: this.suffix,
            ),
            controller: this.controller,
            onChanged: changed,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
