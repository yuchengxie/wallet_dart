import 'package:flutter/material.dart';
import '../../api/miner.dart';

class MinerPage extends StatefulWidget {
  MinerPage({Key key}) : super(key: key);

  _MinerPageState createState() => _MinerPageState();
}

class _MinerPageState extends State<MinerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('123'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('开始挖矿'),
              onPressed: () {
                // print('start miner');
                PoetClient().start();
              },
            ),
            RaisedButton(
              child: Text('停止挖矿'),
              onPressed: () {
                print('stop miner');
              },
            ),
          ],
        ),
      ),
    );
  }
}
