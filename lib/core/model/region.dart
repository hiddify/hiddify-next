import 'package:hiddify/core/localization/translations.dart';

enum Region {
  ir,
  cn,
  ru,
  other;

  String present(TranslationsEn t) => switch (this) {
        ir => t.settings.general.regions.ir,
        cn => t.settings.general.regions.cn,
        ru => t.settings.general.regions.ru,
        other => t.settings.general.regions.other,
      };
}
