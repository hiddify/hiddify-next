import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:hiddify/gen/translations.g.dart';

part 'locale_prefs.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  late final _pref =
      Pref(ref.watch(sharedPreferencesProvider), "locale", AppLocale.en);

  @override
  AppLocale build() => _pref.getValue();

  Future<void> update(AppLocale value) {
    state = value;
    return _pref.update(value);
  }
}

enum AppLocale {
  en,
  fa;

  Locale get locale {
    return Locale(name);
  }

  static List<Locale> get locales =>
      AppLocale.values.map((e) => e.locale).toList();

  static AppLocale fromString(String e) {
    return AppLocale.values.firstOrNullWhere((element) => element.name == e) ??
        AppLocale.en;
  }

  static AppLocale deviceLocale() {
    return AppLocale.fromString(
      AppLocaleUtils.findDeviceLocale().languageCode,
    );
  }

  TranslationsEn translations() {
    final appLocale = AppLocaleUtils.parse(name);
    return appLocale.build();
  }

  String get preferredFontFamily => this == fa ? FontFamily.shabnam : "";
}
