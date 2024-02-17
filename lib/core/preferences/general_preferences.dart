import 'package:flutter/foundation.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'general_preferences.g.dart';

// TODO refactor

bool _debugIntroPage = false;

@Riverpod(keepAlive: true)
class IntroCompleted extends _$IntroCompleted {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "intro_completed",
    false,
  );

  @override
  bool build() {
    if (_debugIntroPage && kDebugMode) return false;
    return _pref.getValue();
  }

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class RegionNotifier extends _$RegionNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "region",
    Region.other,
    mapFrom: Region.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  Region build() => _pref.getValue();

  Future<void> update(Region value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class SilentStartNotifier extends _$SilentStartNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "silent_start",
    false,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class DisableMemoryLimit extends _$DisableMemoryLimit {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "disable_memory_limit",
    // disable memory limit on desktop by default
    PlatformUtils.isDesktop,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class DebugModeNotifier extends _$DebugModeNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "debug_mode",
    ref.read(environmentProvider) == Environment.dev,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class PerAppProxyModeNotifier extends _$PerAppProxyModeNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "per_app_proxy_mode",
    PerAppProxyMode.off,
    mapFrom: PerAppProxyMode.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  PerAppProxyMode build() => _pref.getValue();

  Future<void> update(PerAppProxyMode value) {
    state = value;
    return _pref.update(value);
  }
}

@Riverpod(keepAlive: true)
class PerAppProxyList extends _$PerAppProxyList {
  late final _include = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "per_app_proxy_include_list",
    <String>[],
  );

  late final _exclude = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "per_app_proxy_exclude_list",
    <String>[],
  );

  @override
  List<String> build() =>
      ref.watch(perAppProxyModeNotifierProvider) == PerAppProxyMode.include
          ? _include.getValue()
          : _exclude.getValue();

  Future<void> update(List<String> value) {
    state = value;
    if (ref.read(perAppProxyModeNotifierProvider) == PerAppProxyMode.include) {
      return _include.update(value);
    }
    return _exclude.update(value);
  }
}

@riverpod
class MarkNewProfileActive extends _$MarkNewProfileActive {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "mark_new_profile_active",
    true,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@riverpod
class DynamicNotification extends _$DynamicNotification {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "dynamic_notification",
    true,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@riverpod
class AutoCheckIp extends _$AutoCheckIp {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "auto_check_ip",
    true,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}
