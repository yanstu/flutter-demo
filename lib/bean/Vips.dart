
import 'package:demo/util/config.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show json;

class Vips {
  static List<String> names;

  static initVips() async {
    names = new List();
    String url = Config.url + "/api/getVip";
    var jsonRes;
    final dio = new Dio();
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    for (var dataItem in jsonRes) {
      String temp = dataItem.toString();
      Vips.names.add(temp);
    }
  }
}
