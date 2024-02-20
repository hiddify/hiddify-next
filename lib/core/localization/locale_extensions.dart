import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';

extension AppLocaleX on AppLocale {
  String get preferredFontFamily =>
      this == AppLocale.fa ? FontFamily.shabnam : "";

  String get localeName => switch (flutterLocale.toString()) {
        "en" => "English",
        "fa" => "فارسی",
        "ru" => "Русский",
        "zh" || "zh_CN" => "中文 (中国)",
        "zh_TW" => "中文 (台湾)",
        "tr" => "Türkçe",
        "es" => "Spanish",
        "pt_BR" => "Portuguese (Brazil)",
        _ => "Unknown",
      };
}
