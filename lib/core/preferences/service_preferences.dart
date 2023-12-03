import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_preferences.g.dart';

@Riverpod(keepAlive: true)
class StartedByUser extends _$StartedByUser with AppLogger {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider).requireValue,
    "started_by_user",
    false,
  );

  @override
  bool build() => _pref.getValue();

  Future<void> update(bool value) {
    state = value;
    return _pref.update(value);
  }
}
