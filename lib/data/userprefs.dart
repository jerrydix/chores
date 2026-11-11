import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _prefs;
  static Future init() async => _prefs = await SharedPreferences.getInstance();

  static Future setTheme(int themeIndex) async =>
      await _prefs?.setInt('theme', themeIndex);

  static int getTheme() => _prefs?.getInt('theme') ?? 0;

  static Future setLanguage(int languageIndex) async =>
      await _prefs?.setInt('language', languageIndex);

  static int getLanguage() => _prefs?.getInt('language') ?? -1;

  static Future setNotificationsBool(bool on) async =>
      await _prefs?.setBool('notOn', on);

  static bool getNotificationsBool() => _prefs?.getBool('notOn') ?? false;

  static Future setNotificationInterval(int intervalIndex) async =>
      await _prefs?.setInt('notInterval', intervalIndex);

  static int getNotificationInterval() => _prefs?.getInt('notInterval') ?? 0;
}
