import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Local data source for auth (persists user session)
class AuthLocalDataSource {
  static const _userKey = 'cached_user';
  static const _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  AuthLocalDataSource(this._prefs);

  Future<void> cacheUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  UserModel? getCachedUser() {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  Future<void> cacheToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> clearCache() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_tokenKey);
  }
}
