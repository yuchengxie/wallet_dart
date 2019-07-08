import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AssetRecordPage extends StatefulWidget {
  AssetRecordPage({Key key}) : super(key: key);

  _AssetRecordPageState createState() => _AssetRecordPageState();
}

class _AssetRecordPageState extends State<AssetRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NBC'),
        // backgroundColor: Colors.cyan
      ),
      body: BottomButton(),
    );
  }
}

class BottomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Container(
                height: 50,
                child: RaisedButton.icon(
                  color: Colors.cyan,
                  textColor: Colors.white,
                  label: Text('转账'),
                  icon: Icon(Icons.face),
                  onPressed: () {
                    Navigator.pushNamed(context, '/transferPage');
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 50,
                child: RaisedButton.icon(
                  color: Colors.blue,
                  textColor: Colors.white,
                  label: Text('收款'),
                  icon: Icon(Icons.whatshot),
                  onPressed: () {
                    Navigator.pushNamed(context, '/qrcode');
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 0,
        ),
      ],
    );
  }
}

// <Widget>[
//         RaisedButton(
//           child: Text('123'),
//           onPressed: (){},
//         ),
//         RaisedButton(
//           child: Text('444'),
//           onPressed: (){},
//         ),
//       ],
