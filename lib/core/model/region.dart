import 'package:hiddify/core/localization/translations.dart';

enum Region {
  ir,
  cn,
  ru,
  af,
  other;

  String present(TranslationsEn t) => switch (this) {
        ir => t.settings.general.regions.ir,
        cn => t.settings.general.regions.cn,
        ru => t.settings.general.regions.ru,
        af => t.settings.general.regions.af,
        other => t.settings.general.regions.other,
      };
}
