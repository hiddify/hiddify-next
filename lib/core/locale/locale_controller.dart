import 'package:hiddify/core/locale/locale_pref.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_controller.g.dart';

@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController with AppLogger {
  @override
  LocalePref build() {
    return LocalePref.values[_prefs.getInt(_localeKey) ?? 0];
  }

  static const _localeKey = 'locale';
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  Future<void> change(LocalePref locale) async {
    loggy.debug('changing locale to [$locale]');
    await _prefs.setInt(_localeKey, locale.index);
    state = locale;
  }
}
