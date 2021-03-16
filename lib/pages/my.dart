import 'dart:io';

import 'package:demo/bean/UserRecord.dart';
import 'package:demo/bean/Vips.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;
import 'package:demo/widget/load.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class My extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}

class _MyState extends State<My> {
  var jsonRes;
  final dio = new Dio();
  DateTime lastPopTime;
  var user;
  String avapath = "assets/images/avatar.jpeg";

  Future init() async {
    try {
      String zhanghao = await SharedPreferenceUtil.getString(
          SharedPreferenceUtil.KEY_ACCOUNT);
      await UserRecord.initUserRecord(zhanghao);
      setState(() {
        user = UserRecord.user;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    avatarPath();
    init();
    super.initState();
  }

  Future avatarPath() async {
    try {
      String path = await SharedPreferenceUtil.getString("avatar");
      setState(() async {
        if (path != null) {
          File txt = File(path);
          var dirBool = await txt.exists(); //返回真假
          if (!dirBool) {
            avapath = "assets/images/avatar.jpeg";
          } else {
            avapath = path;
            print('\n\n\n\n' + avapath);
          }
        }
      });
    } catch (e) {}
  }

  _report() async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    final response = await dio.get(Config.url + '/api/report?uid=' + uid);
    if (response.statusCode == 200) {
      jsonRes = json.decode(Tool.decode(response.toString()));
      if (jsonRes['result'].toString() == "true") {
        setState(() {
          user.jifen = (int.parse(user.jifen) + 10).toString();
          user.reportCount = (int.parse(user.reportCount) + 1).toString();
        });
        Tool.toast("签到成功，增加10积分", Colors.greenAccent[200]);
      } else {
        Tool.toast("签到失败，你已经签到过了噢", Colors.redAccent[200]);
      }
    } else {
      Tool.toast("不晓得出了啥问题，发邮件反馈哈", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '我的信息',
              style: TextStyle(color: Colors.white),
            ),
            elevation: 0,
            backgroundColor: Colors.indigo[500],
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                tooltip: "公告",
                icon: const Icon(FontAwesomeIcons.bell),
                onPressed: () {
                  Navigator.pushNamed(context, '/noties');
                },
              );
            }),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.ellipsisV,
                  color: Colors.white,
                ),
                tooltip: "更多",
                onPressed: () {
                  Navigator.pushNamed(context, '/setting');
                },
              )
            ],
          ),
          //drawer: CeBianLan(),
          //UserRecord.email == null ? loadMore() :
          body: null == user || null == user.email  || user.email == "null"
              ? loadMore()
              : _container()),
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

  Widget _container() {
    return Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2 - 40,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 10,
                  )
                ],
                color: Colors.indigo[500],
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Container(
                          alignment: Alignment.center,
                          height: 105,
                          width: 105,
                          decoration: BoxDecoration(
                            color: Colors.indigo[500],
                            borderRadius: BorderRadius.circular(52.5),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 100,
                                backgroundImage: avapath == "assets/images/avatar.jpeg"
                                    ? AssetImage(avapath)
                                    : FileImage(File(avapath)),
                              ),
                              user.vip.toString() == "1"
                                  ? Container(
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundImage:
                                            AssetImage("assets/images/vip.png"),
                                        backgroundColor: Colors.black,
                                      ),
                                    )
                                  : Text("")
                            ],
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  user.email.toString(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Text(
                    user.name.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.indigo[500],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo[500],
                                spreadRadius: 1,
                              )
                            ]),
                        child: FlatButton(
                          onPressed: () {
                            _jifen();
                          },
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.moneyBillAlt,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                '积分',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.indigo[500],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo[500],
                                spreadRadius: 1,
                              )
                            ]),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/mydown');
                          },
                          padding: const EdgeInsets.all(4.5),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.download,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                '下载',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.indigo[500],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo[500],
                                spreadRadius: 1,
                              )
                            ]),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/mystar');
                          },
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.star,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                '收藏',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.indigo[500],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo[500],
                                spreadRadius: 1,
                              )
                            ]),
                        child: FlatButton(
                          color: Color.fromRGBO(62, 80, 181, 1),
                          onPressed: () {
                            _report();
                          },
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.checkSquare,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                '签到',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 40, right: 34, left: 34),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.indigo[500],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.moneyBillAlt,
                                color: Colors.white,
                              ),
                              Text(
                                user.jifen.toString(),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.indigo[500],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.download,
                                  color: Colors.white),
                              Text(
                                user.downCount.toString(),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.indigo[500],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.star,
                                color: Colors.white,
                              ),
                              Text(
                                user.starCount.toString(),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 80,
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.indigo[500],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              Text(
                                user.reportCount.toString(),
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width / 1.93,
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo[500],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            pay();
                          },
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  pay();
                                },
                                title: Text(
                                  "开通VIP",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                subtitle: Text(
                                  "3.5元永久VIP",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                leading: Icon(FontAwesomeIcons.paypal,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]));
  }

  void _jifen() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '积分管理',
            style: TextStyle(fontSize: 14),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "你现有积分：" + user.jifen.toString() + "\n",
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  "软件将会不定期推出赠送积分活动，请加群关注，积分上限为10000。\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextField(
                  onChanged: (value) {
                    code.text = value;
                  },
                  onSubmitted: (value) {
                    code.text = value;
                  },
                  decoration: InputDecoration(
                    labelText: '输入激活码',
                    labelStyle: TextStyle(
                      color: Colors.pink,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightBlue[200],
                      ),
                    ),
                  ),
                ),
                Text(""),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          _activation();
                        }, //按钮点击事件
                        color: Colors.orangeAccent,
                        child: new Text('兑换积分'),
                      ),
                    ),
                    Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          _report();
                        },
                        color: Colors.blueAccent,
                        child: new Text('签到获取'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('加群'),
              onPressed: () async {
                Tool.callQQ(number: 921919979, isGroup: true);
              },
            ),
            new FlatButton(
              child: new Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  var code = TextEditingController();

  _activation() async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = Config.url + '/api/code?code=' + code.text + '&uid=' + uid;
    print("\n\n\n\n" + url + "\n\n\n\n");
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      jsonRes = json.decode(Tool.decode(response.toString()));
      if (jsonRes.toString() == "1") {
        setState(() {
          user.vip = "1";
        });
        Tool.toast("激活VIP成功，谢谢你的捐赠！", Colors.greenAccent[200]);
        Vips.names.removeRange(0, Vips.names.length);
        await Vips.initVips();
      } else if (jsonRes.toString() == "0") {
        Tool.toast("激活VIP失败，是不是哪里搞错了", Colors.redAccent[200]);
      } else if (jsonRes.toString() == "2") {
        Tool.toast("激活失败，已达到上限10000分", Colors.redAccent[200]);
      } else {
        setState(() {
          user.jifen = (int.parse(user.jifen) + int.parse(jsonRes.toString()))
              .toString();
        });
        Tool.toast(
            "激活积分成功，增加" + jsonRes.toString() + "积分！", Colors.greenAccent[200]);
      }
    } else {
      Tool.toast("不晓得出了啥问题，发邮件反馈哈", Colors.red);
    }
  }

  void pay() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '开通VIP',
            style: TextStyle(fontSize: 14),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "您的捐赠是我维护的动力\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      code.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      code.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '输入激活码',
                    labelStyle: TextStyle(
                      color: Colors.pink,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.lightBlue[200],
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    _activation();
                  },
                  child: Text("激活"),
                )
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('购买'),
              onPressed: () async {
                Tool.toast("正在跳转默认浏览器，已复制链接地址", Colors.orangeAccent[200]);
                Clipboard.setData(ClipboardData(
                    text: 'http://www.wzfaka.com/detail/B7015F1C1674327B'));
                if (await canLaunch(
                    'http://www.wzfaka.com/detail/B7015F1C1674327B')) {
                  await launch('http://www.wzfaka.com/detail/B7015F1C1674327B');
                } else {
                  Tool.toast("请求出错", Colors.red);
                }
              },
            ),
            new FlatButton(
              child: new Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }
}
