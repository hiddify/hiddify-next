import 'package:hiddify/core/locale/locale.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
TranslationsEn translations(TranslationsRef ref) =>
    ref.watch(localeControllerProvider).translations();
