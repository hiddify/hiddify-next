import 'package:flutter/material.dart';
import 'package:hiddify/utils/pref_notifier.dart';

final themeModeProvider = AlwaysAlivePrefNotifier.provider(
  "theme_mode",
  ThemeMode.system,
  mapFrom: ThemeMode.values.byName,
  mapTo: (value) => value.name,
);

final trueBlackThemeProvider = AlwaysAlivePrefNotifier.provider(
  "true_black_theme",
  false,
);
