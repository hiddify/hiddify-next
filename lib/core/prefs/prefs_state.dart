import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';

part 'prefs_state.freezed.dart';

@freezed
class PrefsState with _$PrefsState {
  const PrefsState._();

  const factory PrefsState({
    @Default(ClashConfig()) ClashConfig clash,
    @Default(NetworkPrefs()) NetworkPrefs network,
  }) = _PrefsState;
}
