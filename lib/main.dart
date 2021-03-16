import 'dart:io';
import 'package:demo/pages/about.dart';
import 'package:demo/pages/downpage.dart';
import 'package:demo/pages/forgotpassword.dart';
import 'package:demo/pages/friends.dart';
import 'package:demo/pages/noties.dart';
import 'package:demo/pages/settingpage.dart';
import 'package:demo/pages/starpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'util/SharedPreferenceUtil.dart';
import 'widget/bottomNavigationBarWidget.dart';
import 'package:demo/pages/loginPage.dart';

void main() {
  runApp(MyApp());

  // 判断当前设备是否为安卓
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

bool navBarMode = true;
bool copyLink = false;
bool skipView = false;
bool parseLink = false;
bool toastBool = false;

class _MyAppState extends State<MyApp> {
  var page;

  Future _isLogin() async {
    String zhanghao =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    setState(() {
      if (zhanghao == null) {
        page = LoginPage();
      } else {
        page = BottomNavigationBarWidget();
      }
    });
  }

  Future initSetting() async {
    try {
      if (await SharedPreferenceUtil.getBool("navBarMode") == null) {
        await SharedPreferenceUtil.setBool("navBarMode", true);
      } else {
        setState(() async {
          navBarMode = await SharedPreferenceUtil.getBool("navBarMode");
        });
      }
      if (await SharedPreferenceUtil.getBool("copyLink") == null) {
        await SharedPreferenceUtil.setBool("copyLink", false);
      } else {
        setState(() async {
          copyLink = await SharedPreferenceUtil.getBool("copyLink");
        });
      }
      if (await SharedPreferenceUtil.getBool("skipView") == null) {
        await SharedPreferenceUtil.setBool("skipView", false);
      } else {
        setState(() async {
          skipView = await SharedPreferenceUtil.getBool("skipView");
        });
      }
      if (await SharedPreferenceUtil.getBool("parseLink") == null) {
        await SharedPreferenceUtil.setBool("parseLink", false);
      } else {
        setState(() async {
          skipView = await SharedPreferenceUtil.getBool("parseLink");
        });
      }
      if (await SharedPreferenceUtil.getBool("toastBool") == null) {
        await SharedPreferenceUtil.setBool("toastBool", false);
      } else {
        setState(() async {
          toastBool = await SharedPreferenceUtil.getBool("toastBool");
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    initSetting();
    _isLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CN'),
        const Locale('en', 'US'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: page != null
          ? BottomNavigationBarWidget()
          : LoginPage(), //page, //BottomNavigationBarWidget()
      routes: {
        '/home': (context) => BottomNavigationBarWidget(),
        '/setting': (context) => SettingPage(),
        '/login': (context) => LoginPage(),
        '/where': (context) => MyApp(),
        '/about': (context) => About(),
        '/mystar': (context) => StarPage(),
        '/mydown': (context) => DownPage(),
        '/noties': (context) => Noties(),
        '/friends': (context) => Friends(),
        '/forgot': (context) => ForgotPassword(),
      },
    );
  }
}
