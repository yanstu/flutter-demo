import 'dart:async';
import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/send_mail.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Widget/bezierContainer.dart';
import 'dart:convert' show json;
import 'package:flushbar/flushbar.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isButtonEnable = true; //按钮状态  是否可点击
  String buttonText = '发送验证码'; //初始文本
  int count = 60; //初始倒计时时间
  Timer timer; //倒计时的计时器
  TextEditingController mController = TextEditingController();
  var _account = TextEditingController();
  var _pwd = TextEditingController();
  var _email = TextEditingController();
  var _inputCode = TextEditingController();
  var jsonRes;
  final dio = new Dio();

  void _buttonClickListen() {
    setState(() async {
      if (isButtonEnable) {
        //当按钮可点击时
        String checkEmail = validateEmail(_email.text);
        if (checkEmail == null) {
          await SharedPreferenceUtil.setString("email", _email.text);
          String code = await Tool.createEmailCode();
          bool sendingStatus = await sendMail(_email.text, code, context);
          showSnackbar(sendingStatus);
          _initTimer();
          isButtonEnable = false; //按钮状态标记
          return null; //返回null按钮禁止点击
        } else {
          Tool.toast(checkEmail, Colors.red);
        }
      } else {
        return null; //返回null按钮禁止点击
      }
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('返回登录',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  var ok = false;

  Future<void> _register() async {
    String checkName = validateName(_account.text);
    if (checkName == null) {
      String checkPwd = validatePwd(_pwd.text);
      if (checkPwd == null) {
        String checkMail = validateEmail(_email.text);
        if (checkMail == null) {
          /*String oldEmail = await SharedPreferenceUtil.getString("email");
          if (oldEmail != null &&
              _inputCode.text != null &&
              _inputCode.text != "") {
            bool checkEmail =
                oldEmail == _email.text || oldEmail.contains(_email.text);
            if (checkEmail) {
              await validateInputCode(_inputCode.text);
              if (ok) {*/
          final response = await dio.get(Config.url +
              '/api/check?pwd=${_account.text}&name=${_pwd.text}&mail=${_email.text}&code=${_inputCode.text}');
          if (response.statusCode == 200) {
            jsonRes = json.decode(Tool.decode(response.toString()));
            if (jsonRes.toString() == "success") {
              Tool.toast('恭喜账号： ' + _account.text.toString() + " 注册成功！",
                  Colors.greenAccent[200]);
              Navigator.pushNamed(context, '/login');
            } else if (jsonRes.toString() == "nameExist") {
              Tool.toast('用户名已存在，换一个注册吧！', Colors.orangeAccent[200]);
            } else if (jsonRes.toString() == "mailExist") {
              Tool.toast('邮箱已存在，换一个注册吧！', Colors.orangeAccent[200]);
            } else {
              Tool.toast('请求错误', Colors.red);
            }
          } else {
            Tool.toast('请联系管理员，未知错误', Colors.red);
          }
          /*} else {
                Tool.toast("验证码错误", Colors.red);
              }
            } else {
              Tool.toast("邮箱和接收验证码的邮箱不一致", Colors.red);
            }
          } else {
            Tool.toast("请发送验证码", Colors.red);
          }*/
        } else {
          Tool.toast(checkMail, Colors.red);
        }
      } else {
        Tool.toast(checkPwd, Colors.red);
      }
    } else {
      Tool.toast(checkName, Colors.red);
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () async {
        _register();
      },
      color: Colors.orangeAccent,
      hoverColor: Colors.orangeAccent[200],
      focusColor: Colors.orangeAccent[200],
      padding: EdgeInsets.all(0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: InkWell(
            child: Text(
              "注册",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "账号",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                  onChanged: (value) {
                    setState(() {
                      _account.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _account.text = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true))
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "密码",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                  onChanged: (value) {
                    setState(() {
                      _pwd.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _pwd.text = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true))
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "邮箱",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                  onChanged: (value) {
                    setState(() {
                      _email.text = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _email.text = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true))
            ],
          ),
        ),
        /*Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "验证码",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 62,
          color: Color(0xfff3f3f4),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  crossAxisAlignment: CrossAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: TextField(
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        _inputCode.text = value;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _inputCode.text = value;
                      });
                    },
                    controller: mController,
                    textAlign: TextAlign.left,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5)
                    ],
                    decoration: InputDecoration(
                      hintText: ('填写验证码'),
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0),
                      hintStyle: TextStyle(
                        color: Color(0xff999999),
                        fontSize: 13,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              Container(
                width: 120,
                child: FlatButton(
                  disabledColor: Colors.grey.withOpacity(0.1), //按钮禁用时的颜色
                  disabledTextColor: Colors.white, //按钮禁用时的文本颜色
                  textColor: isButtonEnable
                      ? Colors.white
                      : Colors.black.withOpacity(0.2), //文本颜色
                  color: isButtonEnable
                      ? Colors.orangeAccent[200]
                      : Colors.grey.withOpacity(0.1), //按钮的颜色
                  splashColor: isButtonEnable
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  shape: StadiumBorder(side: BorderSide.none),
                  onPressed: () {
                    setState(() {
                      _buttonClickListen();
                    });
                  },
//                        child: Text('重新发送 (${secondSy})'),
                  child: Text(
                    '$buttonText',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),*/
      ],
    );
  }

  void _initTimer() {
    timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      count--;
      setState(() {
        if (count == 0) {
          timer.cancel(); //倒计时结束取消定时器
          isButtonEnable = true; //按钮可点击
          count = 60; //重置时间
          buttonText = '发送验证码'; //重置按钮文本
        } else {
          buttonText = '重新发送($count)'; //更新文本内容
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel(); //销毁计时器
    SharedPreferenceUtil.remove("code");
    SharedPreferenceUtil.remove("email");
    timer = null;
    mController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
                SizedBox(
                  height: 20,
                ),
                _emailPasswordWidget(),
                SizedBox(
                  height: 20,
                ),
                _submitButton(),
                FlatButton(
                    padding: EdgeInsets.only(top: 25),
                    onPressed: () {
                      //_help();
                    },
                    //child: Text("发送失败？收不到验证码？")),
                    child: Text(
                        "\t\t\t\t不要嫌注册麻烦，我已经取消了邮箱验证代码，注册登录只是为了各位用户可以享受云端收藏及下载记录。")),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                )
              ],
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
          Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer())
        ],
      ),
    )));
  }

  void _help() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            '注册帮助',
            style: TextStyle(fontSize: 15),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                Text(
                  "1.显示发送失败\n\t\t\t\t发送失败的话请尝试更换网络，一般可以解决如果，解决不了更换邮箱。\n"
                  "2.显示已发送验证码，但是未收到验证码\n\t\t\t\t因为发送验证码到一个邮箱服务器如果过于频繁，会被当做垃圾邮件处理，虽然有4个邮箱随机发送验证码，但是还是避免不了，所以请前往邮箱的垃圾邮件查看，QQ邮箱反垃圾规则太强。\n"
                  "3.都尝试过，或者是不想花时间去尝试\n\t\t\t\t加群找管理员解决，管理员帮你注册，1 2的解决方法可以解决99%的问题。",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('加群'),
              onPressed: () {
                Tool.callQQ(number: 921919979, isGroup: true);
              },
            ),
            new FlatButton(
                child: new Text('了解'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  String validateName(String value) {
    if (value.length < 4) return '账号名必须至少4个字符';
    final RegExp nameExp = new RegExp(r'^[A-za-z0-9]+$');
    if (!nameExp.hasMatch(value)) return '请输入一个有效的账号名称';
    return null;
  }

  Future validateInputCode(String value) async {
    String oldCode = await SharedPreferenceUtil.getString("code");
    //print('\n\n\n\n' + oldCode + '\n\n\n' + value);
    print(oldCode + '\n\n\n\n' + value);
    if (oldCode == value || oldCode.contains(value)) {
      setState(() {
        ok = true;
      });
    }
  }

  String validatePwd(String value) {
    if (value.length < 6 || value.length > 16) return '密码在6-16位数之间';
    return null;
  }

  String validateEmail(String value) {
    if (value.isEmpty) return '电子邮件不能为空！';

    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    //final RegExp nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');

    if (!regExp.hasMatch(value)) return '无效的电子邮件地址';
    return null;
  }

  void showSnackbar(bool sendingStatus) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: EdgeInsets.all(8),
      borderRadius: 15,
      backgroundGradient: LinearGradient(
        colors: [Colors.lightBlueAccent, Colors.green],
      ),
      backgroundColor: Colors.red,
      boxShadows: [
        BoxShadow(
          color: Colors.blue[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
      //title: "Mesaj Bildirimi",
      message: sendingStatus == true
          ? "验证码已发送，如果没收到，请检查垃圾邮件或者换个邮箱或者联系管理员"
          : "发送错误，请更换一下网络环境或者联系管理员",
      icon: Icon(
        sendingStatus == true ? Icons.done_all : Icons.error,
        size: 28.0,
        color: Colors.white,
      ),
      duration: Duration(seconds: 3),
      //leftBarIndicatorColor: Colors.blue[300],
    )..show(context);
  }
}
