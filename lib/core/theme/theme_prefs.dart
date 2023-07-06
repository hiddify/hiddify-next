import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_prefs.freezed.dart';

@freezed
class ThemePrefs with _$ThemePrefs {
  const ThemePrefs._();

  const factory ThemePrefs({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool trueBlack,
  }) = _ThemePrefs;
}
