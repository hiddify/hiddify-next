// import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/features/common/common_controllers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppView extends HookConsumerWidget with PresLogger {
  const AppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider).flutterLocale;
    final theme = ref.watch(themeProvider);

    ref.watch(commonControllersProvider);

    return MaterialApp.router(
      // builder: (context, child) {
      //   return AccessibilityTools(
      //     checkFontOverflows: true,
      //     child: child,
      //   );
      // },
      // showSemanticsDebugger: true,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: theme.light(),
      darkTheme: theme.dark(),
      title: Constants.appName,

      // https://github.com/ponnamkarthik/FlutterToast/issues/393
      builder: (context, child) => Overlay(
        initialEntries: [
          if (child != null) ...[
            OverlayEntry(
              builder: (context) => child,
            ),
          ],
        ],
      ),
    );
  }
}
