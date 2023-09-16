import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final _loggy = Loggy('bootstrap');
final _stopWatch = Stopwatch();

Future<void> lazyBootstrap(
  WidgetsBinding widgetsBinding,
  Environment env,
) async {
  _stopWatch.start();

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

  if (container.read(autoCrashReportProvider) && !kDebugMode) {
    _loggy.debug("initializing crashlytics");
    await initCrashlytics();
  }

  final debug = container.read(debugModeNotifierProvider) || kDebugMode;

  final filesEditor = container.read(filesEditorServiceProvider);
  await filesEditor.init();

  initLoggers(container.read, debug);
  _loggy.info(
    "os: [${Platform.operatingSystem}](${Platform.operatingSystemVersion}), processor count [${Platform.numberOfProcessors}]",
  );
  _loggy.info("basic setup took [${_stopWatch.elapsedMilliseconds}]ms");

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
  _stopWatch.stop();
  _loggy.info("bootstrapping took [${_stopWatch.elapsedMilliseconds}]ms");
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

Future<void> initCrashlytics() async {
  switch (Platform.operatingSystem) {
    case "android" || "ios" || "macos":
      await Firebase.initializeApp();
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    default:
      _loggy.debug("platform is not supported for crashlytics");
      return;
  }
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
