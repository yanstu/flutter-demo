import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/tool.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import '../Widget/bezierContainer.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /*Future _isLogin() async{
    String zhanghao =
        await SharedPreferenceUtil.get(SharedPreferenceUtil.KEY_ACCOUNT);
        if(zhanghao!=null){

        }
  }*/

  @override
  void initState() {
    super.initState();
  }

  final dio = new Dio();
  var _account = TextEditingController();
  var _pwd = TextEditingController();
  var jsonRes;
  DateTime lastPopTime;

  //用于登录时判断输入的账号、密码是否符合要求
  bool _accountState, _pwdState = false;
  //提示语
  String _checkHint;

  //校验账号是否符合条件
  void _checkAccount() {
    //校验账号不为空且长度大于等于4(自定义校验条件)
    if (_account.text.isNotEmpty && _account.text.trim().length >= 4) {
      _accountState = true;
    } else {
      _accountState = false;
    }
  }

  //校验密码是否符合条件
  void _checkPassword() {
    //校验密码不为空且长度大于等于6小于16(自定义校验条件)
    if (_pwd.text.isNotEmpty &&
        _pwd.text.length >= 6 &&
        _pwd.text.length <= 16) {
      _pwdState = true;
    } else {
      _pwdState = false;
    }
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              onChanged: (value) {
                if (title == "账号") {
                  _account.text = value;
                } else if (title == "密码") {
                  _pwd.text = value;
                }
              },
              onSubmitted: (value) {
                if (title == "账号") {
                  _account.text = value;
                } else if (title == "密码") {
                  _pwd.text = value;
                }
              },
              maxLength: 16,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return FlatButton(
      color: Colors.orangeAccent,
      hoverColor: Colors.orangeAccent[200],
      focusColor: Colors.orangeAccent[200],
      onPressed: () async {
        _checkAccount(); //校验账号格式，以此来更新_accountState
        _checkPassword(); //校验账号格式，以此来更新_passwordState
        if (_accountState) {
          if (_pwdState) {
            final response = await dio.get(Config.url +
                '/api/login?account=${_account.text}&pwd=${_pwd.text}');
            // var url ="http://192.168.0.160/api/login?account=${_account.text}&pwd=${_pwd.text}";
            //var response = await http.get(url);
            //await dio.get(url).then((response) async {
            if (response.statusCode == 200) {
              jsonRes = json.decode(Tool.decode(response.toString()));
              if (jsonRes['result'].toString() == "true") {
                SharedPreferenceUtil.setString(SharedPreferenceUtil.KEY_ACCOUNT,
                    jsonRes['uid'].toString());
                _checkHint = '恭喜账号： ' + _account.text.toString() + " 登录成功！";
              } else {
                _checkHint = '登录失败，请检查账号或密码是否正确。';
              }
            } else {
              _checkHint = '请联系管理员，登录错误：${response.statusCode}';
            }
            //});

          } else {
            _checkHint = '请输入6~16位密码！';
          }
        } else {
          _checkHint = '请输入不低于4位账号！';
        }
        showDialog(
          context: context,
          barrierDismissible: true, //点击弹窗外部是否消失
          child: new AlertDialog(
            title: new Text(
              //标题
              '提示',
              style: new TextStyle(color: Colors.red[300], fontSize: 18),
            ),
            content: new Text(_checkHint), //提示语
            actions: <Widget>[
              new FlatButton(
                  //一个扁平的Material按钮
                  onPressed: () {
                    Navigator.of(context).pop(); //弹窗消失
                  },
                  child: Text('取消')),
              new FlatButton(
                  //对话框按钮
                  onPressed: () async {
                    if (_accountState &&
                        _pwdState &&
                        _checkHint.contains("成功")) {
                      //账号密码都符合条件
                      Navigator.pushNamed(context,
                          '/home'); //使用的是“命名导航路由”，具体去哪个界面，看main.dart 对应routeName（'/Home'）的界面
                    } else {
                      Navigator.of(context).pop(); //弹窗消失
                    }
                  },
                  child: Text('确定')),
            ],
          ),
        );
      },
      padding: EdgeInsets.all(0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: InkWell(
            child: Text(
              "登录",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )),
    );
  }

/*_logUser(String uid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('zhanghao', uid);
}*/

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "还没有账号？",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpPage()));
            },
            child: Text(
              '注册',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: '疾',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: '速',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: '搜索',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("账号"),
        _entryField("密码", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
                  _title(),
                  SizedBox(
                    height: 50,
                  ),
                  _emailPasswordWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  _submitButton(),
                  Align(
                    heightFactor: 3,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot');
                      },
                      child: Text("忘记了账号或密码?"),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _createAccountLabel(),
            ),
            Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer())
          ],
        ),
      ))),
      onWillPop: () async {
        // 点击返回键的操作
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Tool.toast('再按一次退出', Colors.greenAccent);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
    );
  }
}
