import 'package:hiddify/core/prefs/prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
TranslationsEn translations(TranslationsRef ref) =>
    ref.watch(localeProvider).translations();

@Riverpod(keepAlive: true)
AppTheme theme(ThemeRef ref) => AppTheme(
      ref.watch(themeModeProvider),
      ref.watch(trueBlackThemeProvider),
      ref.watch(localeProvider).preferredFontFamily,
    );
