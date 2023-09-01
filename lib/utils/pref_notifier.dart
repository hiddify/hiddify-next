import 'package:hiddify/data/data_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefNotifier<T> extends AutoDisposeNotifier<T> {
  PrefNotifier(this._key, this._defaultValue, this._mapFrom, this._mapTo);

  final String _key;
  final T _defaultValue;
  final T Function(String)? _mapFrom;
  final String Function(T)? _mapTo;

  static AutoDisposeNotifierProvider<PrefNotifier<T>, T> provider<T>(
    String key,
    T defaultValue, {
    T Function(String value)? mapFrom,
    String Function(T value)? mapTo,
  }) =>
      NotifierProvider.autoDispose(
        () => PrefNotifier(key, defaultValue, mapFrom, mapTo),
      );

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  /// Updates the value asynchronously.
  Future<void> update(T value) async {
    if (_mapTo != null && _mapFrom != null) {
      await _prefs.setString(_key, _mapTo!(value));
    } else {
      switch (value) {
        case String _:
          await _prefs.setString(_key, value);
        case bool _:
          await _prefs.setBool(_key, value);
        case int _:
          await _prefs.setInt(_key, value);
        case double _:
          await _prefs.setDouble(_key, value);
        case List<String> _:
          await _prefs.setStringList(_key, value);
      }
    }
    super.state = value;
  }

  @override
  T build() {
    if (_mapTo != null && _mapFrom != null) {
      final persisted = _prefs.getString(_key);
      return persisted != null ? _mapFrom!(persisted) : _defaultValue;
    }
    return _prefs.get(_key) as T? ?? _defaultValue;
  }
}
