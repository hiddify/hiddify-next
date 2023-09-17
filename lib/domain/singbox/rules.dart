import 'package:hiddify/core/prefs/locale_prefs.dart';

enum PerAppProxyMode {
  off,
  include,
  exclude;

  bool get enabled => this != off;

  ({String title, String message}) present(TranslationsEn t) => switch (this) {
        off => (
            title: t.settings.network.perAppProxyModes.off,
            message: t.settings.network.perAppProxyModes.offMsg,
          ),
        include => (
            title: t.settings.network.perAppProxyModes.include,
            message: t.settings.network.perAppProxyModes.includeMsg,
          ),
        exclude => (
            title: t.settings.network.perAppProxyModes.exclude,
            message: t.settings.network.perAppProxyModes.excludeMsg,
          ),
      };
}

enum Region {
  ir,
  cn,
  other;

  String present(TranslationsEn t) => switch (this) {
        ir => t.settings.general.regions.ir,
        cn => t.settings.general.regions.cn,
        other => t.settings.general.regions.other,
      };
}
