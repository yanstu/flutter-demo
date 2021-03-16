import 'dart:convert' show json;
import 'package:demo/bean/Stars.dart';
import 'package:demo/bean/UserRecord.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/tool.dart';
import 'package:demo/widget/load.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_beautiful_popup/main.dart';
import '../main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcePage extends StatefulWidget {
  @override
  _ResourcePageState createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  ScrollController _scrollController = new ScrollController();
  List names = new List();
  var jsonRes;
  DateTime lastPopTime;
  int pageNo = 1;
  var _saved;
  bool haveData = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text("疾速搜索"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              setState(() {
                bellState = false;
              });
              Navigator.pushNamed(context, '/noties');
            },
            icon: Container(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        FontAwesomeIcons.bell,
                        color: Colors.white,
                      ),
                    ),
                    bellState
                        ? Text(
                            "·",
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 65),
                          )
                        : Text("")
                  ],
                )),
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(FontAwesomeIcons.star),
              onPressed: () {
                Navigator.pushNamed(context, '/mystar');
              },
            ),
          ],
        ),
        body: names.length == 0
            ? loading()
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildList(),
              ),
        resizeToAvoidBottomPadding: false,
      ),
      //Tool.toast('再按一次退出',Colors.greenAccent);
      onWillPop: () async {
        // 点击返回键的操作
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Tool.toast('再按一次退出', Colors.lightBlue[200]);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
    );
  }

  final dio = new Dio();

  Future<dynamic> _onRefresh() async {
    names.removeRange(0, names.length);
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url =
        Config.url + "/api/resource?page=1" + "&resid=" + Tool.get(uid);
    print(url);
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var dataItem in jsonRes['data']) {
        names.add(dataItem);
      }
    });
  }

  void _getMoreData() async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url =
        Config.url + "/api/resource?page=$pageNo" + "&resid=" + Tool.get(uid);
    print(url);
    final response = await dio.get(url);
    String data = Tool.decode(response.toString());
    jsonRes = json.decode(data);

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

  Future init() async {
    try {
      await Stars.initStars();
      setState(() {
        _saved = Stars.stars;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    init();
    this._getMoreData();
    super.initState();
    _getNewVersionAPP();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  String serviceVersionCode;
  String content;

  //异步请求
  Future _getNewVersionAPP() async {
    String url = Config.url + "/api/checkUpdate";
    Response response = await Dio().get(url);
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.toString());
      if (jsonRes != null) {
        setState(() {
          serviceVersionCode =
              jsonRes["versionCode"].toString(); //获取服务器的versionCode
          content = jsonRes["content"].toString();
          _checkVersionCode(); //升级app版本的方法
        });
      }
    }
  }

  void _checkVersionCode() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      var currentVersionCode = packageInfo.version; //获取当前的版本号
      if (serviceVersionCode != currentVersionCode) {
        _showNewVersionAppDialog(); //弹出"版本更新"的对话框
      }
    });
  }

  void _showNewVersionAppDialog() {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateSuccess,
    );
    popup.show(title: '新版本v' + serviceVersionCode, content: content, actions: [
      popup.button(
        label: '前往更新',
        onPressed: () async {
          String url = "https://www.lanzous.com/b0aqlvhkb";
          Tool.toast("已复制链接，如果不能启动浏览器请自行打开。", Colors.orangeAccent[200]);
          Clipboard.setData(ClipboardData(text: url));
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Tool.toast("请求出错", Colors.red);
          }
        },
      ),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          return new Container(
            margin: EdgeInsets.all(10),
            child: Align(
              child: loadMore(),
            ),
          );
        }

        var alreadySaved = false;
        if (_saved != null) {
          alreadySaved = _saved.contains((names[index]['rid']));
        }

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
