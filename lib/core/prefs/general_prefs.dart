import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/environment.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'general_prefs.g.dart';

@Riverpod(keepAlive: true)
class SilentStartNotifier extends _$SilentStartNotifier {
  late final _pref =
      Pref(ref.watch(sharedPreferencesProvider), "silent_start", false);

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
    ref.watch(sharedPreferencesProvider),
    "debug_mode",
    ref.read(envProvider) == Environment.dev,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}

@riverpod
class MarkNewProfileActive extends _$MarkNewProfileActive {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
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
