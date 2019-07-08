import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatefulWidget {
  QRCodePage({Key key}) : super(key: key);

  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('我的收款码'),
        ),
        body: Center(
          child: QrImage(
            data: "1118hfRMRrJMgSCoV9ztyPcjcgcMZ1zThvqRDLUw3xCYkZwwTAbJ5o",
            size: 260.0,
            onError: (ex) {
              print("[QR] ERROR - $ex");
            },
          ),
        ));
  }
}
