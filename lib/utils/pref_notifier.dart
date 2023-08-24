import 'package:hiddify/data/data_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefNotifier<T> extends AutoDisposeNotifier<T> {
  PrefNotifier(this._key, this._defaultValue);

  final String _key;
  final T _defaultValue;

  static AutoDisposeNotifierProvider<PrefNotifier<T>, T> provider<T>(
    String key,
    T defaultValue,
  ) =>
      NotifierProvider.autoDispose(
        () => PrefNotifier(key, defaultValue),
      );

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  /// Updates the value asynchronously.
  Future<void> update(T value) async {
    if (value is String) {
      await _prefs.setString(_key, value);
    } else if (value is bool) {
      await _prefs.setBool(_key, value);
    } else if (value is int) {
      await _prefs.setInt(_key, value);
    } else if (value is double) {
      await _prefs.setDouble(_key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(_key, value);
    }
    super.state = value;
  }

  @override
  T build() {
    return _prefs.get(_key) as T? ?? _defaultValue;
  }
}
