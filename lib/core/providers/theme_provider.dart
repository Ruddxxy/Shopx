import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DarkModeNotifier(prefs);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'dark_mode';

  DarkModeNotifier(this._prefs) : super(_prefs.getBool(_darkModeKey) ?? false);

  void toggleDarkMode() {
    state = !state;
    _prefs.setBool(_darkModeKey, state);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('This provider should be overridden with a value from SharedPreferences.getInstance()');
}); 