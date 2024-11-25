import 'package:hot_diamond_admin/src/model/admin_model/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefsHelper {
  static const String usernameKey = "admin_username";
  static const String passwordKey = "admin_password";

  // Save credentials to SharedPreferences
  static Future<void> saveCredentials(AdminCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, credentials.username);
    await prefs.setString(passwordKey, credentials.password);
  }

  // Get stored credentials
  static Future<AdminCredentials> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(usernameKey) ?? 'admin@1';
    final password = prefs.getString(passwordKey) ?? '123';
    return AdminCredentials(username: username, password: password);
  }

  // Clear credentials from SharedPreferences (sign out)
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(usernameKey);
    await prefs.remove(passwordKey);
  }
}
