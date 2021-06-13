import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs
{
  static Future<bool> saveUserID(String id) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString("userid", id);
  }
  static Future<String?> getName() async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    return await prefs.getString("userid");
  }
}