import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pref<T, P> with InfraLogger {
  const Pref(
    this.prefs,
    this.key,
    this.defaultValue, {
    this.mapFrom,
    this.mapTo,
  });

  final SharedPreferences prefs;
  final String key;
  final T defaultValue;
  final T Function(P value)? mapFrom;
  final P Function(T value)? mapTo;

  /// Updates the value asynchronously.
  Future<void> update(T value) async {
    loggy.debug("updating preference [$key]($T) to [$value]");
    Object? mapped = value;
    if (mapTo != null) {
      mapped = mapTo!(value);
    }
    try {
      switch (mapped) {
        case String _:
          await prefs.setString(key, mapped);
        case bool _:
          await prefs.setBool(key, mapped);
        case int _:
          await prefs.setInt(key, mapped);
        case double _:
          await prefs.setDouble(key, mapped);
        case List<String> _:
          await prefs.setStringList(key, mapped);
      }
    } catch (e) {
      loggy.warning("error updating preference[$key]: $e");
    }
  }

  T getValue() {
    try {
      loggy.debug("getting persisted preference [$key]($T)");
      if (mapFrom != null) {
        final persisted = prefs.get(key) as P?;
        if (persisted == null) return defaultValue;
        return mapFrom!(persisted);
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T? ?? defaultValue;
      }
      return prefs.get(key) as T? ?? defaultValue;
    } catch (e) {
      loggy.warning("error getting preference[$key]: $e");
      return defaultValue;
    }
  }
}

class PrefNotifier<T, P> extends AutoDisposeNotifier<T> with InfraLogger {
  PrefNotifier(
    this._key,
    this._defaultValue,
    this._mapFrom,
    this._mapTo,
  );

  final String _key;
  final T _defaultValue;
  final T Function(P value)? _mapFrom;
  final P Function(T)? _mapTo;

  late final Pref<T, P> _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    _key,
    _defaultValue,
    mapFrom: _mapFrom,
    mapTo: _mapTo,
  );

  static AutoDisposeNotifierProvider<PrefNotifier<T, P>, T> provider<T, P>(
    String key,
    T defaultValue, {
    T Function(P value)? mapFrom,
    P Function(T value)? mapTo,
  }) =>
      AutoDisposeNotifierProvider(
        () => PrefNotifier(key, defaultValue, mapFrom, mapTo),
      );

  Future<void> update(T value) async {
    _pref.update(value);
    super.state = value;
  }

  @override
  T build() => _pref.getValue();
}
