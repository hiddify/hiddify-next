import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/features/common/app_update_notifier.dart';
import 'package:hiddify/features/common/common_controllers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:upgrader/upgrader.dart';

bool _debugAccessibility = false;

class AppView extends HookConsumerWidget with PresLogger {
  const AppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider).flutterLocale;
    final theme = ref.watch(themeProvider);

    ref.watch(commonControllersProvider);

    final upgrader = ref.watch(upgraderProvider);

    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode.flutterThemeMode,
      theme: theme.light(),
      darkTheme: theme.dark(),
      title: Constants.appName,
      builder: (context, child) {
        child = UpgradeAlert(
          upgrader: upgrader,
          navigatorKey: router.routerDelegate.navigatorKey,
          child: child ?? const SizedBox(),
        );
        if (kDebugMode && _debugAccessibility) {
          return AccessibilityTools(
            checkFontOverflows: true,
            child: child,
          );
        }
        return child;
      },
    );
  }
}
