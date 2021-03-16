import 'dart:convert';
import 'dart:convert' show json;
import 'dart:math';
import 'package:demo/bean/UserRecord.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

bool bellState = true;

class Tool {

  static final dio = new Dio();

  static pay(String rid) async {
    var jsonRes;
    final dio = new Dio();
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String realUrl;
    realUrl = "https://www.lanzous.com/" + rid;
    String url = Config.url + '/api/download?rid=' + rid + '&uid=' + uid;
    print('\n\n\n\n' + url);
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      jsonRes = json.decode(Tool.decode(response.toString()));
      if (jsonRes.toString() == "true") {
        if (parseLink) {
          if (realUrl.contains("lanzous")) {
            realUrl = await parsingLink(realUrl);
            if (realUrl == "error1") {
              toast("请求出错", Colors.red);
              return;
            } else if (realUrl == "error2") {
              toast("资源链接出错，请联系管理员", Colors.red);
              return;
            }
          }
        }
        if (copyLink) {
          Clipboard.setData(ClipboardData(text: realUrl));
        }
        if (!toastBool) {
          toast("你已经下载过,不扣除积分,使用默认浏览器打开地址", Colors.greenAccent[200]);
        }
        if (await canLaunch(realUrl)) {
          await launch(realUrl);
        } else {
          toast("请求出错", Colors.red);
        }
      } else if (jsonRes.toString() == "nb") {
        if (parseLink) {
          if (realUrl.contains("lanzous")) {
            realUrl = await parsingLink(realUrl);
            if (realUrl == "error1") {
              toast("请求出错", Colors.red);
              return;
            } else if (realUrl == "error2") {
              toast("资源链接出错，请联系管理员", Colors.red);
              return;
            }
          }
        }
        if (copyLink) {
          Clipboard.setData(ClipboardData(text: realUrl));
        }
        if (!toastBool) {
          toast("不敢收VIP的积分,资源拿好,使用默认浏览器打开地址", Colors.greenAccent[200]);
        }
        if (await canLaunch(realUrl)) {
          await launch(realUrl);
        } else {
          toast("请求出错", Colors.red);
        }
      } else if (jsonRes.toString() == "false") {
        UserRecord.user.jifen =
            (int.parse(UserRecord.user.jifen) - 1).toString();
        if (parseLink) {
          if (realUrl.contains("lanzous")) {
            realUrl = await parsingLink(realUrl);
            if (realUrl == "error1") {
              toast("请求出错", Colors.red);
              return;
            } else if (realUrl == "error2") {
              toast("资源链接出错，请联系管理员", Colors.red);
              return;
            }
          }
        }
        if (copyLink) {
          Clipboard.setData(ClipboardData(text: realUrl));
        }
        if (!toastBool) {
          toast("支付成功,再次下载不会扣除积分,使用默认浏览器打开地址", Colors.greenAccent[200]);
        }
        if (await canLaunch(realUrl)) {
          await launch(realUrl);
        } else {
          toast("请求出错", Colors.red);
        }
      } else if (jsonRes.toString() == "xxx") {
        toast("积分不足请签到", Colors.redAccent[200]);
      } else {
        toast("请求出错", Colors.red);
      }
    } else {
      toast("请求出错", Colors.red);
    }
  }

  static Future<String> parsingLink(String link) async {
    if (!link.contains("www")) {
      link = link.replaceAll("lanzou", "www.lanzou");
    }
    if (!link.contains("http")) {
      link = link.replaceAll("www", "https://www");
    }
    print(link);
    final response =
        await dio.get('http://api.028haoma.com/lzjx/1.php?parse=' + link);
    print(response.toString());
    if (response.statusCode == 200) {
      var jsonRes = json.decode(response.toString());
      if (jsonRes["info"].toString() == "sucess") {
        String url = jsonRes["text"]["url"].toString().replaceAll("////", "//");
        if (url.contains("=")) {
          url = url.substring(0, url.indexOf("="));
        }
        print(url);
        return url;
      } else {
        return "error2";
      }
    } else {
      return "error1";
    }
  }

  static toast(String msg, Color color) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String get(String uid) {
    var dai = (DateTime.now().hour + DateTime.now().minute).toString();
    var content = utf8.encode(dai);
    var digest = base64Encode(content);
    var content2 = utf8.encode(digest);
    var digest2 = base64Encode(content2);
    String str = "";
    try {
      str = uid + digest2.replaceAll("=", "");
    } catch (e) {}
    return str;
  }

  static Future<String> createEmailCode() async {
    String code = "";
    for (int i = 0; i < 5; i++) {
      code += (Random().nextInt(10)).toString();
    }
    await SharedPreferenceUtil.setString("code", code);
    return code;
  }

  /// 吊起QQ
  /// [number]QQ号
  /// [isGroup]是否是群号,默认是,不是群号则直接跳转聊天
  static void callQQ({int number, bool isGroup}) async {
    String url = isGroup
        ? 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${number ?? 0}&card_type=group&source=qrcode'
        : 'mqqwpa://im/chat?chat_type=wpa&uin=${number ?? 0}&version=1&src_type=web&web_src=oicqzone.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Tool.toast('检测到未安装QQ', Colors.red);
    }
  }

  static String decode(String data) {
    data = data.replaceAll("alone", "a");
    data = data.replaceAll("baby", "b");
    data = data.replaceAll("cancel", "c");
    data = data.replaceAll("duang", "d");
    data = data.replaceAll("khwfp", "k");
    try {
      data = utf8.decode(base64Url.decode(data));
      //print(data);
      return data;
    } catch (e) {
      print("解析错误！" + e.toString());
    }
    return "null";
  }
}
