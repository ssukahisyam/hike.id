import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hike.id punya tiga visual mode (DESIGN.md §9):
/// - light, dark (mengikuti sistem), outdoor (high-contrast manual).
enum HThemeMode {
  system,
  light,
  dark,
  outdoor;

  bool get followSystem => this == HThemeMode.system;

  String get label {
    switch (this) {
      case HThemeMode.system:
        return 'Ikut sistem';
      case HThemeMode.light:
        return 'Terang';
      case HThemeMode.dark:
        return 'Gelap';
      case HThemeMode.outdoor:
        return 'Outdoor (kontras tinggi)';
    }
  }

  static HThemeMode fromName(String? name) {
    return HThemeMode.values.firstWhere(
      (HThemeMode e) => e.name == name,
      orElse: () => HThemeMode.system,
    );
  }
}

const String _kThemePrefKey = 'theme_mode';

class ThemeModeController extends StateNotifier<HThemeMode> {
  ThemeModeController(this._prefs)
      : super(HThemeMode.fromName(_prefs.getString(_kThemePrefKey)));

  final SharedPreferences _prefs;

  Future<void> set(HThemeMode mode) async {
    state = mode;
    await _prefs.setString(_kThemePrefKey, mode.name);
  }
}

/// Provider for SharedPreferences. Initialize in main() lewat overrideWithValue.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final StateNotifierProvider<ThemeModeController, HThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeController, HThemeMode>((Ref ref) {
  return ThemeModeController(ref.watch(sharedPreferencesProvider));
});

/// Resolves [HThemeMode] to Material [ThemeMode].
ThemeMode resolveMaterialThemeMode(HThemeMode mode) {
  switch (mode) {
    case HThemeMode.system:
      return ThemeMode.system;
    case HThemeMode.light:
    case HThemeMode.outdoor:
      return ThemeMode.light;
    case HThemeMode.dark:
      return ThemeMode.dark;
  }
}
