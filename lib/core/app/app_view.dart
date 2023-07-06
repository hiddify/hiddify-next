import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/theme/theme.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppView extends HookConsumerWidget with PresLogger {
  const AppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider).locale;
    final theme = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: LocalePref.locales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: theme.light,
      darkTheme: theme.dark,
      title: 'Hiddify',
    ).animate().fadeIn();
  }
}
