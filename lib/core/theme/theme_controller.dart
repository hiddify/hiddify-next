import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/theme_prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController with AppLogger {
  @override
  ThemePrefs build() {
    return ThemePrefs(
      themeMode: ThemeMode.values[_prefs.getInt(_themeModeKey) ?? 0],
      trueBlack: _prefs.getBool(_trueBlackKey) ?? false,
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  static const _themeModeKey = "theme_mode";
  static const _trueBlackKey = "true_black";

  Future<void> change({
    ThemeMode? themeMode,
    bool? trueBlack,
  }) async {
    loggy.debug('changing theme, mode=$themeMode, trueBlack=$trueBlack');
    if (themeMode != null) {
      await _prefs.setInt(_themeModeKey, themeMode.index);
    }
    if (trueBlack != null) {
      await _prefs.setBool(_trueBlackKey, trueBlack);
    }
    state = state.copyWith(
      themeMode: themeMode ?? state.themeMode,
      trueBlack: trueBlack ?? state.trueBlack,
    );
  }
}
