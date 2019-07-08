import 'package:flutter/material.dart';

class TxnDetailsPage extends StatefulWidget {
  TxnDetailsPage({Key key}) : super(key: key);

  _TxnDetailsPageState createState() => _TxnDetailsPageState();
}

class _TxnDetailsPageState extends State<TxnDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('111'),),
      body: Center(
        child: Text('222'),
      ),
    );
  }
}
