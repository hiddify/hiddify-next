import 'package:hiddify/core/locale/locale.dart';

enum ProfilesSort {
  lastUpdate,
  name;

  String present(TranslationsEn t) {
    return switch (this) {
      lastUpdate => t.profile.sortBy.lastUpdate,
      name => t.profile.sortBy.name,
    };
  }
}
