import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefNotifier<T> extends AutoDisposeNotifier<T>
    with _Prefs<T>, InfraLogger {
  PrefNotifier(
    this.key,
    this.defaultValue,
    this.mapFrom,
    this.mapTo,
  );

  @override
  final String key;
  @override
  final T defaultValue;
  @override
  final T Function(String)? mapFrom;
  @override
  final String Function(T)? mapTo;

  static AutoDisposeNotifierProvider<PrefNotifier<T>, T> provider<T>(
    String key,
    T defaultValue, {
    T Function(String value)? mapFrom,
    String Function(T value)? mapTo,
  }) =>
      AutoDisposeNotifierProvider(
        () => PrefNotifier(key, defaultValue, mapFrom, mapTo),
      );

  @override
  SharedPreferences get prefs => ref.read(sharedPreferencesProvider);

  @override
  Future<void> update(T value) async {
    super.update(value);
    super.state = value;
  }

  @override
  T build() => getValue();
}

class AlwaysAlivePrefNotifier<T> extends Notifier<T>
    with _Prefs<T>, InfraLogger {
  AlwaysAlivePrefNotifier(
    this.key,
    this.defaultValue,
    this.mapFrom,
    this.mapTo,
  );

  @override
  final String key;
  @override
  final T defaultValue;
  @override
  final T Function(String)? mapFrom;
  @override
  final String Function(T)? mapTo;

  static NotifierProvider<AlwaysAlivePrefNotifier<T>, T> provider<T>(
    String key,
    T defaultValue, {
    T Function(String value)? mapFrom,
    String Function(T value)? mapTo,
  }) =>
      NotifierProvider(
        () => AlwaysAlivePrefNotifier(key, defaultValue, mapFrom, mapTo),
      );

  @override
  SharedPreferences get prefs => ref.read(sharedPreferencesProvider);

  @override
  Future<void> update(T value) async {
    super.update(value);
    super.state = value;
  }

  @override
  T build() => getValue();
}

mixin _Prefs<T> implements LoggerMixin {
  String get key;
  T get defaultValue;
  T Function(String)? get mapFrom;
  String Function(T)? get mapTo;

  SharedPreferences get prefs;

  /// Updates the value asynchronously.
  Future<void> update(T value) async {
    if (mapTo != null && mapFrom != null) {
      await prefs.setString(key, mapTo!(value));
    } else {
      switch (value) {
        case String _:
          await prefs.setString(key, value);
        case bool _:
          await prefs.setBool(key, value);
        case int _:
          await prefs.setInt(key, value);
        case double _:
          await prefs.setDouble(key, value);
        case List<String> _:
          await prefs.setStringList(key, value);
      }
    }
  }

  T getValue() {
    try {
      if (mapTo != null && mapFrom != null) {
        final persisted = prefs.getString(key);
        return persisted != null ? mapFrom!(persisted) : defaultValue;
      }
      return prefs.get(key) as T? ?? defaultValue;
    } catch (e) {
      loggy.warning("error getting preference[$key]: $e");
      return defaultValue;
    }
  }
}
