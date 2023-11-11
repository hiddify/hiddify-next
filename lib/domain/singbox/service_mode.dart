import 'package:hiddify/core/prefs/locale_prefs.dart';
import 'package:hiddify/utils/platform_utils.dart';

enum ServiceMode {
  proxy,
  systemProxy,
  tun;

  static ServiceMode get defaultMode =>
      PlatformUtils.isDesktop ? systemProxy : tun;

  static List<ServiceMode> get choices {
    if (PlatformUtils.isDesktop) {
      return values;
    }
    return [proxy, tun];
  }

  String present(TranslationsEn t) => switch (this) {
        proxy => t.settings.config.serviceModes.proxy,
        systemProxy => t.settings.config.serviceModes.systemProxy,
        tun => t.settings.config.serviceModes.tun,
      };
}
