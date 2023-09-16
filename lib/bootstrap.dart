import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hiddify/core/app/app.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/data/repository/app_repository_impl.dart';
import 'package:hiddify/domain/environment.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/features/common/window/window_controller.dart';
import 'package:hiddify/features/system_tray/system_tray.dart';
import 'package:hiddify/services/auto_start_service.dart';
import 'package:hiddify/services/deep_link_service.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final _loggy = Loggy('bootstrap');
const _testCrashReport = false;

Future<void> lazyBootstrap(
  WidgetsBinding widgetsBinding,
  Environment env,
) async {
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (PlatformUtils.isDesktop) await windowManager.ensureInitialized();

  final appInfo = await AppRepositoryImpl.getAppInfo(env);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      appInfoProvider.overrideWithValue(appInfo),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final enableAnalytics = container.read(enableAnalyticsProvider);

  await SentryFlutter.init(
    (options) {
      if ((enableAnalytics && !kDebugMode) || _testCrashReport) {
        options.dsn = Environment.sentryDSN;
      } else {
        options.dsn = "";
      }

      options.environment = env.toString();
      options.debug = kDebugMode;
    },
    appRunner: () => _lazyBootstrap(widgetsBinding, container, env),
  );
}

Future<void> _lazyBootstrap(
  WidgetsBinding widgetsBinding,
  ProviderContainer container,
  Environment env,
) async {
  final debug = container.read(debugModeNotifierProvider) || kDebugMode;

  final filesEditor = container.read(filesEditorServiceProvider);
  await filesEditor.init();

  initLoggers(container.read, debug);
  _loggy.info(
    "os: [${Platform.operatingSystem}](${Platform.operatingSystemVersion}), processor count [${Platform.numberOfProcessors}]",
  );

  final silentStart = container.read(silentStartNotifierProvider);
  if (silentStart) {
    FlutterNativeSplash.remove();
  }
  if (PlatformUtils.isDesktop) {
    await container.read(autoStartServiceProvider.future);
    await container.read(windowControllerProvider.future);
  }

  await initAppServices(container.read);
  await initControllers(container.read);

  runApp(
    ProviderScope(
      parent: container,
      child: const AppView(),
    ),
  );

  if (!silentStart) FlutterNativeSplash.remove();
}

void initLoggers(
  Result Function<Result>(ProviderListenable<Result>) read,
  bool debug,
) {
  final logLevel = debug ? LogLevel.all : LogLevel.info;
  final logToFile = debug || (!Platform.isAndroid && !Platform.isIOS);
  Loggy.initLoggy(
    logPrinter: MultiLogPrinter(
      const PrettyPrinter(),
      logToFile
          ? FileLogPrinter(read(filesEditorServiceProvider).appLogsPath)
          : null,
    ),
    logOptions: LogOptions(logLevel),
  );
}

Future<void> initAppServices(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  _loggy.debug("initializing app services");
  await Future.wait(
    [
      read(singboxServiceProvider).init(),
    ],
  );
  _loggy.debug('initialized app services');
}

Future<void> initControllers(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  _loggy.debug("initializing controllers");
  await Future.wait(
    [
      read(activeProfileProvider.future),
      read(deepLinkServiceProvider.future),
      if (PlatformUtils.isDesktop) read(systemTrayControllerProvider.future),
    ],
  );
  _loggy.debug("initialized base controllers");
}
