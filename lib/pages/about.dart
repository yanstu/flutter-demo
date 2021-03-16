import 'package:demo/util/tool.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _launchMailto() async {
      const url = 'mailto:fastsearch@126.com';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text('关于软件'),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.shareAlt,size: 18,),
              onPressed: () {
                Share.share(
                    '【疾速搜索】\n 蓝奏云资源搜索利器，这里不止只有安卓应用。 \n https://www.lanzous.com/b0aqlvhkb');
              })
        ],
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/images/avatar.jpg"),
            ),
            SizedBox(
              height: 10,
            ),
            Text('疾速搜索'),
            Text('\t\t\t\t不采用直接解析蓝奏云链接真实下载地址，保留蓝奏云网页的广告，全部资源来源于网络。'),
            SizedBox(
              height: 5,
            ),
            Divider(
              color: Colors.grey,
              indent: 30.0,
              endIndent: 30.0,
              thickness: 1,
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.black,
              textColor: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.envelope),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'fastsearch@126.com',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
              onPressed: () {
                _launchMailto();
              },
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.blueGrey,
              textColor: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.qq),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '921919979                     ',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
              onPressed: () async {
                Tool.callQQ(number: 921919979, isGroup: true);
              },
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.orangeAccent,
              textColor: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.internetExplorer),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'www.lanzou.cc             ',
                    style: TextStyle(fontSize: 15),
                  )
                ],
              ),
              onPressed: () async {
                if (await canLaunch('http://www.lanzou.cc')) {
                  await launch('http://www.lanzou.cc');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
