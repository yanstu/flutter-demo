import 'dart:convert';
import 'dart:io';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:flutter_beautiful_popup/templates/Success.dart';
import 'package:settings_ui/settings_ui.dart';

import '../main.dart';
import 'package:demo/bean/UserRecord.dart';
import 'package:demo/bean/Vips.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final dio = new Dio();

  void _launchMailto() async {
    const url = 'mailto:check6@126.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text("更多"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: '账户相关',
            tiles: [
              SettingsTile(
                title: "更换头像",
                leading: Icon(
                  FontAwesomeIcons.solidUserCircle,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  _updateAvatar();
                },
              ),
              SettingsTile(
                title: "修改昵称",
                leading: Icon(
                  FontAwesomeIcons.user,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  _updateUserName();
                },
              ),
              SettingsTile(
                title: "修改密码",
                leading: Icon(
                  FontAwesomeIcons.edit,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  _updateUserPwd();
                },
              ),
              SettingsTile(
                title: "退出登录",
                leading: Icon(
                  FontAwesomeIcons.signOutAlt,
                  color: Colors.lightBlue,
                ),
                onTap: () async {
                  await SharedPreferenceUtil.remove(
                      SharedPreferenceUtil.KEY_ACCOUNT);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
          SettingsSection(
            title: '会员功能',
            tiles: [
              SettingsTile.switchTile(
                title: '直接下载资源，跳过进入蓝奏云链接',
                leading: Icon(
                  FontAwesomeIcons.angleDoubleDown,
                  color: Colors.lightBlue,
                ),
                switchValue: parseLink,
                onToggle: (bool value) async {
                  if (UserRecord.user.vip == "1") {
                    setState(() {
                      parseLink = value;
                    });
                    await SharedPreferenceUtil.setBool("parseLink", value);
                  } else {
                    Tool.toast("请捐赠开启会员功能。", Colors.red[200]);
                  }
                },
              ),
              SettingsTile(
                title: "蓝奏云直链提取",
                leading: Icon(
                  FontAwesomeIcons.fileCode,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  if (UserRecord.user.vip == "1") {
                    parsing();
                  } else {
                    Tool.toast("请捐赠开启会员功能。", Colors.red[200]);
                  }
                },
              ),
              SettingsTile(
                title: "蓝奏云密码破解",
                leading: Icon(
                  FontAwesomeIcons.code,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  if (UserRecord.user.vip == "1") {
                    Tool.toast("正在开发，敬请期待。", Colors.greenAccent[200]);
                  } else {
                    Tool.toast("请捐赠开启会员功能。", Colors.red[200]);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: '应用设置',
            tiles: [
              SettingsTile.switchTile(
                title: '下载并复制蓝奏云链接',
                leading: Icon(
                  FontAwesomeIcons.copy,
                  color: Colors.lightBlue,
                ),
                switchValue: copyLink,
                onToggle: (bool value) async {
                  setState(() {
                    copyLink = value;
                  });
                  await SharedPreferenceUtil.setBool("copyLink", value);
                },
              ),
              SettingsTile.switchTile(
                title: '跳过查看应用详情直接支付下载',
                leading: Icon(
                  FontAwesomeIcons.eyeSlash,
                  color: Colors.lightBlue,
                ),
                switchValue: skipView,
                onToggle: (bool value) async {
                  setState(() {
                    skipView = value;
                  });
                  await SharedPreferenceUtil.setBool("skipView", value);
                },
              ),
              SettingsTile.switchTile(
                title: '不提示支付积分消息',
                leading: Icon(
                  FontAwesomeIcons.solidBellSlash,
                  color: Colors.lightBlue,
                ),
                switchValue: toastBool,
                onToggle: (bool value) async {
                  setState(() {
                    toastBool = value;
                  });
                  await SharedPreferenceUtil.setBool("toastBool", value);
                },
              ),
              SettingsTile.switchTile(
                title: '首页底部显示样式切换',
                leading: Icon(
                  FontAwesomeIcons.tachometerAlt,
                  color: Colors.lightBlue,
                ),
                switchValue: navBarMode,
                onToggle: (bool value) async {
                  setState(() {
                    navBarMode = value;
                  });
                  await SharedPreferenceUtil.setBool("navBarMode", value);
                },
              ),
              SettingsTile(
                title: "下载器更换",
                leading: Icon(
                  FontAwesomeIcons.cloudDownloadAlt,
                  color: Colors.lightBlue,
                ),
                onTap: () async {
                  //Tool.toast('Could not launch $url', Colors.greenAccent[200]);
                  const url = 'imd:';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    //Tool.toast('Could not launch $url', Colors.red);
                    Tool.toast('正在开发，敬请期待', Colors.red);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: '其他',
            tiles: [
              SettingsTile(
                title: "好友推荐",
                leading: Icon(
                  FontAwesomeIcons.userFriends,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/friends');
                },
              ),
              SettingsTile(
                title: "加入QQ群",
                leading: Icon(
                  FontAwesomeIcons.qq,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  Tool.callQQ(number: 921919979, isGroup: true);
                },
              ),
              SettingsTile(
                title: "检查更新",
                leading: Icon(
                  FontAwesomeIcons.cloudUploadAlt,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  _getNewVersionAPP();
                },
              ),
              SettingsTile(
                title: "发送反馈",
                leading: Icon(
                  FontAwesomeIcons.facebookMessenger,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  _launchMailto();
                },
              ),
              SettingsTile(
                title: "关于软件",
                leading: Icon(
                  FontAwesomeIcons.bolt,
                  color: Colors.lightBlue,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  File _image;

  void _updateAvatar() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: const Text('选择'),
        //message: const Text('Please select the best mode from the options below.'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('本地相册'),
            onPressed: () {
              Navigator.pop(context, '本地相册');
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('相机'),
            onPressed: () {
              Navigator.pop(context, '相机');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('关闭'),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, '关闭');
          },
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        if (value == "相机") {
          getImageByCamera();
        } else if (value == "本地相册") {
          getImageByGallery();
        }
      }
    });
  }

  Future updateAvatarPath() async {
    await SharedPreferenceUtil.setString("avatar", _image.path);
    Tool.toast("上传成功，图片仍然本地路径，请勿删除！重启生效。", Colors.greenAccent[200]);
    print('\n\n\n\n' + _image.path);
  }

  Future getImageByCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    updateAvatarPath();
  }

  Future getImageByGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    updateAvatarPath();
  }

  String serviceVersionCode;
  String content;

  //异步请求
  Future _getNewVersionAPP() async {
    String url = Config.url + "/api/checkUpdate";
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.toString());
      if (jsonRes != null) {
        setState(() {
          serviceVersionCode =
              jsonRes["versionCode"].toString(); //获取服务器的versionCode
          content = jsonRes["content"].toString();
          print('\n\n\n\n' + serviceVersionCode);
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
      } else {
        Tool.toast("当前已是最新版，没有船新版本", Colors.orangeAccent[200]);
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

  var parsingUrl = TextEditingController();

  void parsing() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '直链解析',
            style: TextStyle(fontSize: 14),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "  因为这个功能好像并没有什么卵用，所以我就只随便搞了无密码的链接解析，如果有人需要请联系我，我加个有密码的解析。\n",
                  style: TextStyle(fontSize: 13),
                ),
                Text("蓝奏云链接："),
                TextField(
                  onChanged: (value) {
                    parsingUrl.text = value;
                  },
                ),
                Text(""),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          parsingLink("copy");
                        }, //按钮点击事件
                        color: Colors.orangeAccent,
                        child: new Text('复制地址'),
                      ),
                    ),
                    Expanded(
                      child: new RaisedButton(
                        onPressed: () {
                          parsingLink("open");
                        },
                        color: Colors.blueAccent,
                        child: new Text('直接打开'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
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

  var oldPwd = TextEditingController();
  var newPwd = TextEditingController();

  void _updateUserPwd() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '修改昵称',
            style: TextStyle(fontSize: 14),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "旧密码",
                  style: TextStyle(fontSize: 13),
                ),
                TextField(
                  onChanged: (value) {
                    oldPwd.text = value;
                  },
                  onSubmitted: (value) {
                    oldPwd.text = value;
                  },
                ),
                Text(
                  "\n新密码",
                  style: TextStyle(fontSize: 13),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      newPwd.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      newPwd.text = value;
                    });
                  },
                ),
                Text(""),
                RaisedButton(
                  onPressed: () async {
                    if (newPwd.text.length >= 6 && newPwd.text.length <= 16) {
                      String uid = await SharedPreferenceUtil.getString(
                          SharedPreferenceUtil.KEY_ACCOUNT);
                      String url = Config.url +
                          '/api/upPwd?uid=' +
                          uid +
                          '&oldPwd=' +
                          oldPwd.text +
                          '&newPwd=' +
                          newPwd.text;
                      final response = await dio.get(url);
                      if (response.statusCode == 200) {
                        var jsonRes =
                            json.decode(Tool.decode(response.toString()));
                        if (jsonRes.toString() != "error") {
                          Tool.toast("密码修改成功！", Colors.greenAccent[200]);
                          Navigator.of(context).pop();
                        } else {
                          Tool.toast("原密码错误或者请求出错！", Colors.red[200]);
                        }
                      } else {
                        Tool.toast("请求出错", Colors.red);
                      }
                    } else {
                      Tool.toast("原密码在6-16位数之间", Colors.red[200]);
                    }
                  },
                  child: Text(
                    "修改",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
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

  Future<void> parsingLink(String type) async {
    String url = "";
    String link = parsingUrl.text;
    if (!link.contains("www")) {
      link = link.replaceAll("lanzou", "www.lanzou");
    }
    if (!link.contains("http")) {
      link = link.replaceAll("www", "https://www");
    }
    final response =
        await dio.get('http://api.028haoma.com/lzjx/1.php?parse=' + link);
    if (response.statusCode == 200) {
      var jsonRes = json.decode(Tool.decode(response.toString()));
      if (jsonRes["info"].toString() == "sucess") {
        url = jsonRes["text"]["url"].toString().replaceAll("////", "//");
        if (url.contains("=")) {
          url = url.substring(0, url.indexOf("="));
        }
        if (type == "copy") {
          Tool.toast("已复制解析后的链接", Colors.greenAccent[200]);
          Clipboard.setData(ClipboardData(text: url));
        } else if (type == "open") {
          Tool.toast("正在启动默认浏览器打开网页", Colors.greenAccent[200]);
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Tool.toast("请求出错", Colors.red);
          }
        }
      } else {
        Tool.toast("链接错误！", Colors.red);
      }
    } else {
      Tool.toast("请求出错，请联系管理员", Colors.red);
    }
  }

  var name = TextEditingController();

  void _updateUserName() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '修改昵称',
            style: TextStyle(fontSize: 14),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "你要修改什么帅气的昵称呢？\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      name.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      name.text = value;
                    });
                  },
                  maxLength: 16,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('不改'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('修改'),
              onPressed: () async {
                String uid = await SharedPreferenceUtil.getString(
                    SharedPreferenceUtil.KEY_ACCOUNT);
                String url = Config.url +
                    '/api/updateName?name=' +
                    name.text +
                    '&uid=' +
                    uid;
                print("\n\n\n\n" + url + "\n\n\n\n");
                await dio.get(url);
                Tool.toast("修改成功！你的新名字为：" + name.text, Colors.greenAccent[200]);
                setState(() {
                  UserRecord.user.name = name.text;
                });
                Vips.names.removeRange(0, Vips.names.length);
                await Vips.initVips();
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
