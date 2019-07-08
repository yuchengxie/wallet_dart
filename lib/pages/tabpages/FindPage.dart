import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class FindPage extends StatefulWidget {
  FindPage({Key key}) : super(key: key);

  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('发现'),
          // backgroundColor: Colors.cyan,
        ),
        body: Container(
          child: SwiperDiy(
            swiperDataList: [
              {
                'image': 'https://www.itying.com/images/flutter/1.png',
              },
              {
                'image': 'https://www.itying.com/images/flutter/2.png',
              },
              {
                'image': 'https://www.itying.com/images/flutter/3.png',
              },
            ],
          ),
        ));
  }
}

class SwiperDiy extends StatelessWidget {
  final List swiperDataList;
  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network("${swiperDataList[index]['image']}",
              fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}
