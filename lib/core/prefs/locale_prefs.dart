import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:hiddify/gen/translations.g.dart';

part 'locale_prefs.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
    "locale",
    AppLocaleUtils.findDeviceLocale(),
    mapFrom: AppLocale.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  AppLocale build() => _pref.getValue();

  Future<void> update(AppLocale value) {
    state = value;
    return _pref.update(value);
  }
}

extension AppLocaleX on AppLocale {
  String get preferredFontFamily =>
      this == AppLocale.fa ? FontFamily.shabnam : "";
}
