import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/environment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
AppInfo appInfo(AppInfoRef ref) =>
    throw UnimplementedError('AppInfo must be overridden');

@Riverpod(keepAlive: true)
Environment env(EnvRef ref) => ref.watch(appInfoProvider).environment;

@Riverpod(keepAlive: true)
TranslationsEn translations(TranslationsRef ref) =>
    ref.watch(localeNotifierProvider).build();

@Riverpod(keepAlive: true)
AppTheme theme(ThemeRef ref) => AppTheme(
      ref.watch(themeModeNotifierProvider),
      ref.watch(localeNotifierProvider).preferredFontFamily,
    );
