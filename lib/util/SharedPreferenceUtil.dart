import 'package:shared_preferences/shared_preferences.dart';

/// create on 2019/5/30 by JasonZhang
/// desc：本地储存
class SharedPreferenceUtil {
  static const String KEY_ACCOUNT = "zhanghao";
  static const String KEY_MYINFO = "myinfo";

  // 异步保存
  static Future setString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  // 异步读取
  static Future<String> getString(String key) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      return sp.getString(key);
    } catch (e) {}
  }

  // 异步保存
  static Future setBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool(key, value);
  }

  // 异步读取
  static Future<bool> getBool(String key) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      return sp.getBool(key);
    } catch (e) {}
  }

  // 异步保存
  static Future setInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt(key, value);
  }

  // 异步读取
  static Future<int> getInt(String key) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      return sp.getInt(key);
    } catch (e) {}
  }

  //移除
  static Future<String> remove(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove(key);
  }
}
