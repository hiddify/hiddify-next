import 'package:hiddify/core/locale/locale.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final translationsProvider = Provider<TranslationsEn>(
  (ref) => ref.watch(localeControllerProvider).translations(),
);
