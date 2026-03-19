import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class DemoModeService {
  static const _kEnabledKey = 'demo_enabled';
  static const _kRoleKey = 'demo_role';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  static Future<void> enable({required UserRole role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, true);
    await prefs.setString(_kRoleKey, role.name);
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, false);
    await prefs.remove(_kRoleKey);
  }

  static Future<UserRole> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRoleKey);
    return raw == UserRole.admin.name ? UserRole.admin : UserRole.inspector;
  }
}

