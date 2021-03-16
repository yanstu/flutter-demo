import 'dart:async';
import 'dart:convert';

import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/send_mail.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _kanit = 'Kanit';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();
  var _inputCode = TextEditingController();
  String buttonText = '发送验证码'; //初始文本
  bool isButtonEnable = true; //按钮状态  是否可点击
  int count = 60; //初始倒计时时间
  Timer timer; //倒计时的计时器
  var jsonRes;
  final dio = new Dio();

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) && value.length < 5) {
      return '请输入正确的邮箱格式';
    } else {
      return null;
    }
  }

  Future forgotAccount() async {
    String checkEmail = emailValidator(email.text);
    String account = "";
    if (checkEmail == null) {
      String url = Config.url + "/api/forgotAccount?email=" + email.text;
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        var jsonRes = json.decode(Tool.decode(response.toString()));
        account = jsonRes.toString();
      } else {
        Tool.toast("请求出错，请联系管理员", Colors.red);
        return;
      }
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(
              '忘记账号',
              style: TextStyle(fontSize: 14),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Text(
                    "您的账号为\n",
                    style: TextStyle(fontSize: 13),
                  ),
                  Center(
                    child: Text(account == "null" ? "没有找到此邮箱注册的账号" : account),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('复制并关闭'),
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: account));
                  Navigator.of(context).pop();
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
    } else {
      Tool.toast(checkEmail, Colors.red);
    }
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

  var ok = false;

  Future forgoPassWord() async {
    String checkEmail = emailValidator(email.text);
    String password = "";
    if (checkEmail == null) {
      await validateInputCode(_inputCode.text);
      if (_inputCode.text != null && _inputCode.text != "" && ok) {
        String url = Config.url +
            "/api/forgotPassword?email=" +
            email.text +
            "&code=" +
            _inputCode.text;
        final response = await dio.get(url);
        if (response.statusCode == 200) {
          var jsonRes = json.decode(Tool.decode(response.toString()));
          password = jsonRes.toString();
        } else {
          Tool.toast("请求出错，请联系管理员", Colors.red);
          return;
        }
        showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text(
                '忘记密码',
                style: TextStyle(fontSize: 14),
              ),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    Text(
                      "您的密码为\n",
                      style: TextStyle(fontSize: 13),
                    ),
                    Center(
                      child:
                          Text(password == "null" ? "没有找到此邮箱注册的账号" : password),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('复制并关闭'),
                  onPressed: () async {
                    Clipboard.setData(ClipboardData(text: password));
                    Navigator.of(context).pop();
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
      } else {
        Tool.toast("验证码不能为空或者验证码错误", Colors.red);
      }
    } else {
      Tool.toast(checkEmail, Colors.red);
    }
  }

  resetPassword() {
    emailValidator(email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '忘记账号或密码',
            style: TextStyle(
              fontFamily: _kanit,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                semanticContainer: true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        '忘记账号',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: _kanit,
                            fontSize: 20.0,
                            color: Colors.black54),
                      ),
                      SizedBox(height: 20),
                      Form(
                        child: TextFormField(
                          controller: email,
                          validator: emailValidator,
                          cursorColor: Colors.lightBlueAccent,
                          style: TextStyle(color: Colors.lightBlueAccent[700]),
                          decoration: InputDecoration(
                            hoverColor: Colors.lightBlueAccent,
                            labelText: '邮箱',
                            errorStyle: TextStyle(
                              fontFamily: _kanit,
                            ),
                            labelStyle: TextStyle(
                                fontFamily: _kanit,
                                color: Colors.lightBlueAccent),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            filled: true,
                            prefixIcon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.grey,
                            ),
                            fillColor: Color.alphaBlend(
                              Colors.lightBlueAccent.withOpacity(.09),
                              Colors.grey.withOpacity(.04),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.lightBlueAccent, width: 1.5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.lightBlueAccent,
                              Colors.lightBlueAccent[700]
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: MaterialButton(
                          onPressed: forgotAccount,
                          child: Text(
                            '查找',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: _kanit,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                semanticContainer: true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        '忘记密码',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: _kanit,
                            fontSize: 20.0,
                            color: Colors.black54),
                      ),
                      SizedBox(height: 20),
                      Form(
                        child: TextFormField(
                          maxLines: 1,
                          onChanged: (value) {
                            setState(() {
                              _inputCode.text = value;
                            });
                          },
                          cursorColor: Colors.lightBlueAccent,
                          style: TextStyle(color: Colors.lightBlueAccent[700]),
                          decoration: InputDecoration(
                            hoverColor: Colors.lightBlueAccent,
                            labelText: '验证码',
                            errorStyle: TextStyle(
                              fontFamily: _kanit,
                            ),
                            labelStyle: TextStyle(
                                fontFamily: _kanit,
                                color: Colors.lightBlueAccent),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            filled: true,
                            prefixIcon: Icon(
                              FontAwesomeIcons.key,
                              color: Colors.grey,
                            ),
                            fillColor: Color.alphaBlend(
                              Colors.lightBlueAccent.withOpacity(.09),
                              Colors.grey.withOpacity(.04),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.lightBlueAccent, width: 1.5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // Color.fromRGBO(0, 255, 0, 20),
                                    // Color.fromRGBO(220, 200, 0, 10)
                                    Colors.lightBlueAccent,
                                    Colors.lightBlueAccent[700]
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: MaterialButton(
                                onPressed: forgoPassWord,
                                child: Text(
                                  '提交',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: _kanit,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.lightBlueAccent[700]
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    _buttonClickListen();
                                  });
                                },
                                child: Text(
                                  buttonText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: _kanit,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              heightFactor: 3,
              child: Text("找回密码请在上方忘记账号处输入邮箱，下面发送验证码。"),
            )
          ],
        ));
  }

  void _buttonClickListen() {
    setState(() async {
      if (isButtonEnable) {
        //当按钮可点击时
        String checkEmail = emailValidator(email.text);
        if (checkEmail == null) {
          await SharedPreferenceUtil.setString("email", email.text);
          String code = await Tool.createEmailCode();
          bool sendingStatus = await sendMail(email.text, code, context);
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
    super.dispose();
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
          : "发送错误，请重新尝试发送验证码",
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
