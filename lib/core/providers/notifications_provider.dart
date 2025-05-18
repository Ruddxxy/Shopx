import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

final pushNotificationsProvider = StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationsNotifier(prefs);
});

class NotificationsNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _pushNotificationsKey = 'push_notifications_enabled';

  NotificationsNotifier(this._prefs) : super(_prefs.getBool(_pushNotificationsKey) ?? true);

  Future<void> togglePushNotifications() async {
    state = !state;
    await _prefs.setBool(_pushNotificationsKey, state);
  }
} 