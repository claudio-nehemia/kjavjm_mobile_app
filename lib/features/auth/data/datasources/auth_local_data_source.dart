import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_USER = 'CACHED_USER';
  static const String AUTH_TOKEN = 'AUTH_TOKEN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_USER);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        CACHED_USER,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove(CACHED_USER);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user cache');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AUTH_TOKEN);
    } catch (e) {
      throw CacheException(message: 'Failed to get token');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AUTH_TOKEN, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await sharedPreferences.remove(AUTH_TOKEN);
    } catch (e) {
      throw CacheException(message: 'Failed to clear token');
    }
  }
}