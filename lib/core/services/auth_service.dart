import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  final SharedPreferences _prefs;
  final SupabaseClient _supabase;
  Timer? _refreshTimer;

  AuthService(this._prefs, this._supabase) {
    _setupTokenRefresh();
  }

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  String? get userId => _prefs.getString(_userIdKey);
  DateTime? get tokenExpiry => _prefs.getString(_tokenExpiryKey) != null
      ? DateTime.parse(_prefs.getString(_tokenExpiryKey)!)
      : null;

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
    required String userId,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    await _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    await _prefs.setString(_userIdKey, userId);
    _setupTokenRefresh();
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);
    await _prefs.remove(_userIdKey);
    _refreshTimer?.cancel();
  }

  void _setupTokenRefresh() {
    _refreshTimer?.cancel();
    final expiry = tokenExpiry;
    if (expiry != null) {
      final timeUntilRefresh = expiry.difference(DateTime.now()) - const Duration(minutes: 5);
      if (timeUntilRefresh.isNegative) {
        _refreshToken();
      } else {
        _refreshTimer = Timer(timeUntilRefresh, _refreshToken);
      }
    }
  }

  Future<void> _refreshToken() async {
    try {
      final response = await _supabase.auth.refreshSession();
      if (response.session != null) {
        await setTokens(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          expiry: DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt!),
          userId: response.session!.user.id,
        );
      }
    } catch (e) {
      await clearTokens();
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await clearTokens();
    } catch (e) {
      // Handle sign out error
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final supabase = Supabase.instance.client;
  return AuthService(prefs, supabase);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences first');
}); 