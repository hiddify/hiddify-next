import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_prefs.freezed.dart';
part 'general_prefs.g.dart';

@freezed
class GeneralPrefs with _$GeneralPrefs {
  const GeneralPrefs._();

  const factory GeneralPrefs({
    // desktop only
    @Default(false) bool silentStart,
  }) = _GeneralPrefs;

  factory GeneralPrefs.fromJson(Map<String, dynamic> json) =>
      _$GeneralPrefsFromJson(json);
}
