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

final _logger = Loggy('bootstrap');
const _testCrashReport = false;
final _loggers = MultiLogPrinter(const PrettyPrinter(), []);

Future<void> lazyBootstrap(
  WidgetsBinding widgetsBinding,
  Environment env,
) async {
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (PlatformUtils.isDesktop) await windowManager.ensureInitialized();
  Loggy.initLoggy();

  final appInfo = await AppRepositoryImpl.getAppInfo(env);
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      appInfoProvider.overrideWithValue(appInfo),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final enableAnalytics = container.read(enableAnalyticsProvider);
  final sentryLogger = SentryLoggyIntegration();
  _loggers.addPrinter(sentryLogger);

  await SentryFlutter.init(
    (options) {
      if ((enableAnalytics && !kDebugMode) || _testCrashReport) {
        options.dsn = Environment.sentryDSN;
      } else {
        options.dsn = "";
      }

      options.environment = env.name;
      options.dist = appInfo.release.name;
      options.debug = kDebugMode;
      options.enableNativeCrashHandling = true;
      options.enableNdkScopeSync = true;
      options.attachThreads = true;
      options.tracesSampleRate = 0.25;
      options.addIntegration(sentryLogger);
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
  _logger.info(
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
      child: SentryUserInteractionWidget(
        child: const AppView(),
      ),
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
  if (logToFile) {
    _loggers.addPrinter(
      FileLogPrinter(read(filesEditorServiceProvider).appLogsPath),
    );
  }
  Loggy.initLoggy(
    logPrinter: _loggers,
    logOptions: LogOptions(logLevel),
  );
}

Future<void> initAppServices(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  _logger.debug("initializing app services");
  await Future.wait(
    [
      read(singboxServiceProvider).init(),
    ],
  );
  _logger.debug('initialized app services');
}

Future<void> initControllers(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  _logger.debug("initializing controllers");
  await Future.wait(
    [
      read(activeProfileProvider.future),
      read(deepLinkServiceProvider.future),
      if (PlatformUtils.isDesktop) read(systemTrayControllerProvider.future),
    ],
  );
  _logger.debug("initialized base controllers");
}
