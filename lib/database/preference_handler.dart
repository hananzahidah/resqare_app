import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyIsLogin = "isLogin";

  static Future<void> setLogin(bool isLogin) async {
    await _prefs.setBool(_keyIsLogin, isLogin);
  }

  static bool get isLogin {
    return _prefs.getBool(_keyIsLogin) ?? false;
  }

  static const _keyUserId = "userId";

  static Future<void> setUserId(int userId) async {
    await _prefs.setInt(_keyUserId, userId);
  }

  static int get userId {
    return _prefs.getInt(_keyUserId) ?? 0;
  }

  static const _keyUserRole = "userRole";

  static Future<void> setUserRole(String role) async {
    await _prefs.setString(_keyUserRole, role);
  }

  static String get userRole {
    return _prefs.getString(_keyUserRole) ?? "";
  }

  static Future<void> logOut() async {
    await _prefs.remove(_keyIsLogin);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserRole);
  }
}
