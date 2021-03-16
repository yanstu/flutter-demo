import 'dart:convert' show json;
import 'package:demo/bean/Stars.dart';
import 'package:demo/bean/UserRecord.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/tool.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:dio/dio.dart';
import 'package:demo/widget/load.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class DownPage extends StatefulWidget {
  @override
  _DownPageState createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> {
  ScrollController _scrollController = new ScrollController();
  List names = new List();
  var jsonRes;
  DateTime lastPopTime;
  final dio = new Dio();
  bool haveData = true;
  int pageNo = 1;
  final _saved = Stars.stars;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载记录"),
        centerTitle: true,
      ),
      body: names.length == 0
          ? loading()
          : RefreshIndicator(onRefresh: _onRefresh, child: _buildList()),
      resizeToAvoidBottomPadding: false,
    );
  }

  void _getMoreData() async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url =
        Config.url + "/api/mydown?page=$pageNo" + "&resid=" + Tool.get(uid);
    print(url);
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));

    setState(() {
      for (var dataItem in jsonRes['data']) {
        names.add(dataItem);
      }
    });

    if (jsonRes['next'] == "noexist") {
      setState(() {
        haveData = false;
      });
    } else {
      setState(() {
        pageNo++;
        haveData = true;
      });
    }
  }

  @override
  void initState() {
    this._getMoreData();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (haveData) {
          _getMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<dynamic> _onRefresh() async {
    names.removeRange(0, names.length);
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = Config.url + "/api/mydown?page=1&resid=" + Tool.get(uid);
    print(url);
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var dataItem in jsonRes['data']) {
        names.add(dataItem);
      }
    });
    if (jsonRes['next'] == "noexist") {
      setState(() {
        haveData = false;
      });
    } else {
      setState(() {
        pageNo++;
        haveData = true;
      });
    }
  }

  Widget _buildList() {
    return ListView.builder(
      ///保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: names.length * 2 + 1,
      itemBuilder: (BuildContext context, int i) {
        if (i % 2 != 0) return new Divider();
        final index = i ~/ 2;
        if (index == names.length) {
          return haveData ? loadMore() : noLoadMore();
        }

        final alreadySaved = _saved.contains((names[index]['rid']));

        String icon = (names[index]['icon']);
        String filename = "";
        if (!(names[index]['name'])
            .toString()
            .contains((names[index]['icon']))) {
          filename = (names[index]['name']).toString();
        } else {
          filename = (names[index]['name'])
              .toString()
              .substring(0, (names[index]['name']).toString().lastIndexOf("."));
        }
        return Container(
          child: ListTile(
            title: Text(
              filename,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              (names[index]['formattime']) +
                  "\t\t\t\t" +
                  (names[index]['size']),
              style: TextStyle(fontSize: 13),
            ),
            leading: Image.network(
              Config.url + "/png/$icon.png",
              width: 25,
            ),
            trailing: Container(
                width: 50,
                child: FlatButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.transparent,
                    child: Icon(
                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (alreadySaved) {
                          _saved.remove((names[index]['rid']));
                          Stars.unstar((names[index]['rid']));
                        } else {
                          _saved.add((names[index]['rid']));
                          Stars.star((names[index]['rid']));
                        }
                      });
                    })),
            onTap: () {
              if (skipView) {
                Tool.pay((names[index]['rid']));
              } else {
                showDialog(
                    context: context,
                    builder: (_) => AssetGiffyDialog(
                          image: Image.asset(
                            "assets/images/load.gif",
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.w600),
                          ),
                          description: Text(
                            '文件大小：' +
                                (names[index]['size']) +
                                '\n分享日期：' +
                                (names[index]['formattime']) +
                                '\n当前积分：' +
                                UserRecord.user.jifen,
                            textAlign: TextAlign.left,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.DEFAULT,
                          onOkButtonPressed: () {
                            Tool.pay((names[index]['rid']));
                          },
                          buttonOkText: Text("下载"),
                          buttonCancelText: Text("不需要"),
                        ));
              }
            },
          ),
        );
      },
      controller: _scrollController,
    );
  }
}
