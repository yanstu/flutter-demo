import 'dart:convert';

import 'package:demo/bean/Friend.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final dio = new Dio();
  var jsonRes;
  List<Friend> friends = [];
  String url = Config.url + "/api/myfriends";

  Future<dynamic> query() async {
    final response = await dio.get(url);
    print(response.toString());
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var noties in jsonRes) {
        friends.add(new Friend(
            noties["id"].toString(),
            noties["avatar"].toString(),
            noties["name"].toString(),
            noties["link"].toString(),
            noties["type"].toString(),
            noties["content"].toString()));
      }
    });
  }

  @override
  void initState() {
    query();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text("好友推荐"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: _buideList(),
    );
  }

  Widget _buideList() {
    return Card(
      child: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (BuildContext context, int index) {
          return friends.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: friends.length,
                      itemBuilder: (BuildContext context, int index) {
                        return friendCard(friends[index]);
                      }));
        },
      ),
    );
  }

  Widget renderCover(Friend data) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: Image.network(
            data.avatar,
            height: 120,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
          left: 0,
          top: 100,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(0, 0, 0, 0),
                  Color.fromARGB(80, 0, 0, 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget renderUserInfo(Friend data) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 2)),
                    Text(
                      data.link,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            alignment: Alignment.centerRight,
          )
        ],
      ),
    );
  }

  Widget renderPublishContent(Friend data) {
    String type = "";
    if (data.type == "1") {
      type = "应用软件";
    } else if (data.type == "0") {
      type = "公众号";
    } else {
      print(data.type);
      type = "网站";
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 14),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFFFFC600),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '# $type',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            data.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget friendCard(Friend data) {
    return Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 4,
              color: Color.fromARGB(20, 0, 0, 0),
            ),
          ],
        ),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () async {
            String url = "";
            switch (data.type) {
              case "0":
                url = 'weixin://';
                break;
              default:
                url = data.link;
                break;
            }
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              this.renderCover(data),
              this.renderUserInfo(data),
              this.renderPublishContent(data),
              Padding(
                padding: EdgeInsets.all(10),
              )
            ],
          ),
        ));
  }
}
