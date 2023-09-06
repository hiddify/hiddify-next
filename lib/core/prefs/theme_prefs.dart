import 'package:flutter/material.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_prefs.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
    "theme_mode",
    ThemeMode.system,
    mapFrom: ThemeMode.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  ThemeMode build() => _pref.getValue();

  Future<void> update(ThemeMode value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class TrueBlackThemeNotifier extends _$TrueBlackThemeNotifier {
  late final _pref =
      Pref(ref.watch(sharedPreferencesProvider), "true_black_theme", false);

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}
