import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentLoginService {
  static const String _keyUser = 'cached_user';
  static const String _keyLoginTime = 'login_time';
  static const String _keyToken = 'auth_token';
  
  // Auto logout after 1 hour of inactivity
  static const Duration autoLogoutDuration = Duration(hours: 1);

  final SharedPreferences _prefs;

  PersistentLoginService(this._prefs);

  // Save login data
  Future<void> saveLoginData({
    required Map<String, dynamic> user,
    required String token,
  }) async {
    final loginTime = DateTime.now().millisecondsSinceEpoch;
    
    await _prefs.setString(_keyUser, jsonEncode(user));
    await _prefs.setString(_keyToken, token);
    await _prefs.setInt(_keyLoginTime, loginTime);
  }

  // Get cached user if still valid
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final userString = _prefs.getString(_keyUser);
      final token = _prefs.getString(_keyToken);
      final loginTime = _prefs.getInt(_keyLoginTime);

      if (userString == null || token == null || loginTime == null) {
        return null;
      }

      // Check if login has expired
      final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();
      
      if (now.difference(loginDateTime) > autoLogoutDuration) {
        // Auto logout - clear cached data
        await clearLoginData();
        return null;
      }

      // Update login time to extend session
      await _prefs.setInt(_keyLoginTime, now.millisecondsSinceEpoch);

      final userData = jsonDecode(userString) as Map<String, dynamic>;
      userData['token'] = token;
      
      return userData;
    } catch (e) {
      return null;
    }
  }

  // Get cached token
  Future<String?> getCachedToken() async {
    try {
      final token = _prefs.getString(_keyToken);
      final loginTime = _prefs.getInt(_keyLoginTime);

      if (token == null || loginTime == null) {
        return null;
      }

      // Check if login has expired
      final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();
      
      if (now.difference(loginDateTime) > autoLogoutDuration) {
        // Auto logout - clear cached data
        await clearLoginData();
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in and session is valid
  Future<bool> isLoggedIn() async {
    final cachedUser = await getCachedUser();
    return cachedUser != null;
  }

  // Clear all login data
  Future<void> clearLoginData() async {
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyLoginTime);
  }

  // Update activity timestamp to extend session
  Future<void> updateActivity() async {
    final loginTime = _prefs.getInt(_keyLoginTime);
    if (loginTime != null) {
      await _prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);
    }
  }

  // Get time until auto logout
  Duration? getTimeUntilLogout() {
    final loginTime = _prefs.getInt(_keyLoginTime);
    if (loginTime == null) return null;

    final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
    final expiryTime = loginDateTime.add(autoLogoutDuration);
    final now = DateTime.now();

    if (now.isAfter(expiryTime)) {
      return Duration.zero;
    }

    return expiryTime.difference(now);
  }
}