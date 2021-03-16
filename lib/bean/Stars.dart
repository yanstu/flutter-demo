import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

class Stars {
  static Set<String> stars;

  static initStars() async {
    stars = new Set();
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = Config.url + "/api/getStars?uid=" + uid;
    var jsonRes;
    final dio = new Dio();
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    for (var dataItem in jsonRes) {
      String temp = dataItem.toString();
      Stars.stars.add(temp);
    }
    return stars;
  }

  static star(String rid) async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = Config.url + "/api/addStar?uid=" + uid + "&rid=" + rid;
    final dio = new Dio();
    await dio.get(url);
    stars.add(rid);
  }

  static unstar(String rid) async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = Config.url + "/api/rmStar?uid=" + uid + "&rid=" + rid;
    final dio = new Dio();
    await dio.get(url);
    stars.remove(rid);
  }
}
