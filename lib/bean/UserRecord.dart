import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

import 'User.dart';

class UserRecord {
  
  static User user;

  static initUserRecord(String uid) async {
    
    String url = Config.url + "/api/getUserRecord?uid="+uid;
    var jsonRes;
    final dio = new Dio();
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.data.toString()));
    user = new User(jsonRes["downCount"], jsonRes["reportCount"], jsonRes["jifen"], jsonRes["email"], jsonRes["name"], jsonRes["starCount"], jsonRes["vip"], uid);

  }
}
