import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nbc_wallet/api/provider/stateModel.dart';
import 'package:provider/provider.dart';

Widget buildListData(BuildContext context, String titleItem, Icon iconItem,
    String subTitleItem) {
  return new ListTile(
    leading: iconItem,
    title: new Text(
      titleItem,
      style: TextStyle(fontSize: 18),
    ),
    subtitle: new Text(
      subTitleItem,
    ),
    trailing: new Icon(Icons.keyboard_arrow_right),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(
              'ListViewAlert',
              style: new TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            ),
            content: new Text('您选择的item内容为:$titleItem'),
          );
        },
      );
    },
  );
}

class AssetPage extends StatefulWidget {
  AssetPage({Key key}) : super(key: key);

  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  //测试
  @override
  Widget build(BuildContext context) {
    // StateModel _stateModel=Provider.of<StateModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('资产'),),
        body: Column(
      children: <Widget>[
        Container(
          height: 220,
          child: Row(
              children: <Widget>[
                Expanded(
                  child:Image.network('https://www.itying.com/images/flutter/1.png',
                  fit: BoxFit.cover,)
                )
              ],
              ),
        ),
        ListTileCoin(),
      ],
    ));
  }
}

class AssetHead extends StatelessWidget {
  const AssetHead({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}

class ListTileCoin extends StatelessWidget {
  const ListTileCoin({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            child: Image.asset('images/a.jpeg'),
          ),
          title: Text(
            'NBC',
          ),
          subtitle: Text(
            '= 0.0000 RMB',
          ),
          onTap: () {
            Navigator.pushNamed(context, '/assetRecordPage');
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        Divider(
          height: 10,
        ),
      ],
    );
  }
}
