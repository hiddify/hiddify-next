import 'package:hiddify/core/prefs/locale_prefs.dart';

enum CoreMode {
  none,
  proxy,
  tun;

  String present(TranslationsEn t) => switch (this) {
        none => t.settings.config.modes.none,
        proxy => t.settings.config.modes.proxy,
        tun => t.settings.config.modes.tun,
      };
}
