import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_prefs.freezed.dart';
part 'network_prefs.g.dart';

@freezed
class NetworkPrefs with _$NetworkPrefs {
  const NetworkPrefs._();

  const factory NetworkPrefs({
    @Default(true) bool systemProxy,
    @Default(true) bool bypassPrivateNetworks,
  }) = _NetworkPrefs;

  factory NetworkPrefs.fromJson(Map<String, dynamic> json) =>
      _$NetworkPrefsFromJson(json);
}
