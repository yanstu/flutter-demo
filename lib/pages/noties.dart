import 'dart:math';

import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show json;

import 'package:flutter/services.dart';

class Noties extends StatefulWidget {
  @override
  _NotiesState createState() => _NotiesState();
}

class _NotiesState extends State<Noties> {
  final dio = new Dio();
  var jsonRes;
  List notiess = new List();
  String url = Config.url + "/api/getNotice";

  Future<dynamic> _onRefresh() async {
    if (notiess != null && notiess.length != 0) {
      notiess.removeRange(0, notiess.length);
    }
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var noties in jsonRes) {
        notiess.add(noties);
      }
    });
  }

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("软件公告"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
              itemCount: notiess.length,
              itemBuilder: (BuildContext context, int index) {
                return FlipCard(
                  direction: FlipDirection.VERTICAL, //基于X轴翻转
                  front: Container(
                    height: 200,
                    width: 345,
                    margin: EdgeInsets.all(10),
                    color: Color.fromRGBO(
                        new Random().nextInt(255),
                        new Random().nextInt(255),
                        new Random().nextInt(255),
                        1),
                    child: Center(
                      child: Text(notiess[index]["title"],
                          style: TextStyle(fontSize: 40, color: Colors.white)),
                    ),
                  ),
                  back: Container(
                      height: 200,
                      width: 345,
                      margin: EdgeInsets.all(10),
                      color: Color.fromRGBO(
                          new Random().nextInt(255),
                          new Random().nextInt(255),
                          new Random().nextInt(255),
                          1),
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          Tool.toast("已复制网站公告内容", Colors.orangeAccent[200]);
                          Clipboard.setData(
                              ClipboardData(text: notiess[index]["content"]));
                        },
                        child: Text(notiess[index]["content"],
                            style: TextStyle(color: Colors.white, height: 2.0)),
                      )),
                );
              }),
        ));
  }
}
