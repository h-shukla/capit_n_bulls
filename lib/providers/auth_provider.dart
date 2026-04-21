import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _kAccessTokenKey = 'access_token';
const _kRefreshTokenKey = 'refresh_token';

enum AuthStatus { loading, authenticated, unauthenticated }

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  late SharedPreferences _prefs;

  String? accessToken;
  String? refreshToken;

  @override
  Future<AuthStatus> build() async {
    _prefs = await SharedPreferences.getInstance();

    accessToken = _prefs.getString(_kAccessTokenKey);
    refreshToken = _prefs.getString(_kRefreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return AuthStatus.authenticated;
    }

    return AuthStatus.unauthenticated;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveTokens(data);
        state = const AsyncData(AuthStatus.authenticated);
      } else {
        state = AsyncError(
          data['detail'] ?? "Login failed",
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncError("Network error", st);
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/auth/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveTokens(data);
        state = const AsyncData(AuthStatus.authenticated);
      } else {
        state = AsyncError(
          data['detail'] ?? "Signup failed",
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncError("Network error", st);
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_kAccessTokenKey);
    await _prefs.remove(_kRefreshTokenKey);

    accessToken = null;
    refreshToken = null;

    state = const AsyncData(AuthStatus.unauthenticated);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    accessToken = data['access_token'];
    refreshToken = data['refresh_token'];

    await _prefs.setString(_kAccessTokenKey, accessToken!);
    await _prefs.setString(_kRefreshTokenKey, refreshToken!);
  }
}
