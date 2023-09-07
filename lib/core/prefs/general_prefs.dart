import 'package:hiddify/data/data_providers.dart';
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
  late final _pref =
      Pref(ref.watch(sharedPreferencesProvider), "debug_mode", false);

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}
