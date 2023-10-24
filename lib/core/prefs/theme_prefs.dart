import 'package:hiddify/core/prefs/app_theme.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_prefs.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
    "theme_mode",
    AppThemeMode.system,
    mapFrom: AppThemeMode.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  AppThemeMode build() => _pref.getValue();

  Future<void> update(AppThemeMode value) {
    state = value;
    return _pref.update(value);
  }
}
