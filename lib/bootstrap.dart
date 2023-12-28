import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/directories/directories_provider.dart';
import 'package:hiddify/core/logger/logger.dart';
import 'package:hiddify/core/logger/logger_controller.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_migration.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/app/widget/app.dart';
import 'package:hiddify/features/common/window/window_controller.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_data_providers.dart';
import 'package:hiddify/features/log/data/log_data_providers.dart';
import 'package:hiddify/features/profile/data/profile_data_providers.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/system_tray/system_tray_controller.dart';
import 'package:hiddify/services/auto_start_service.dart';
import 'package:hiddify/services/deep_link_service.dart';
import 'package:hiddify/singbox/service/singbox_service_provider.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> lazyBootstrap(
  WidgetsBinding widgetsBinding,
  Environment env,
) async {
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Loggy.initLoggy(logPrinter: const PrettyDeveloperPrinter());

  FlutterError.onError = Logger.logFlutterError;
  WidgetsBinding.instance.platformDispatcher.onError =
      Logger.logPlatformDispatcherError;

  final stopWatch = Stopwatch()..start();
  if (PlatformUtils.isDesktop) await windowManager.ensureInitialized();

  final container = ProviderContainer(
    overrides: [
      environmentProvider.overrideWithValue(env),
    ],
  );

  await _init(
    "directories",
    () => container.read(appDirectoriesProvider.future),
  );
  LoggerController.init(container.read(logPathResolverProvider).appFile().path);

  final appInfo = await _init(
    "app info",
    () => container.read(appInfoProvider.future),
  );
  await _init(
    "preferences",
    () => container.read(sharedPreferencesProvider.future),
  );

  final enableAnalytics =
      await container.read(analyticsControllerProvider.future);
  if (enableAnalytics) {
    await _init(
      "analytics",
      () => container
          .read(analyticsControllerProvider.notifier)
          .enableAnalytics(),
    );
  }

  await _init(
    "preferences migration",
    () async {
      try {
        await PreferencesMigration(
          sharedPreferences:
              container.read(sharedPreferencesProvider).requireValue,
        ).migrate();
      } catch (e, stackTrace) {
        Logger.bootstrap.error("preferences migration failed", e, stackTrace);
        if (env == Environment.dev) rethrow;
        Logger.bootstrap.info("clearing preferences");
        await container.read(sharedPreferencesProvider).requireValue.clear();
      }
    },
  );

  final debug = container.read(debugModeNotifierProvider) || kDebugMode;

  await _init(
    "logs repository",
    () => container.read(logRepositoryProvider.future),
  );
  await _init("logger controller", () => LoggerController.postInit(debug));
  Logger.bootstrap.info(appInfo.format());

  await _init(
    "geo assets repository",
    () => container.read(geoAssetRepositoryProvider.future),
  );
  await _init(
    "profile repository",
    () => container.read(profileRepositoryProvider.future),
  );

  final silentStart = container.read(silentStartNotifierProvider);
  Logger.bootstrap
      .debug("silent start [${silentStart ? "Enabled" : "Disabled"}]");
  if (silentStart) {
    FlutterNativeSplash.remove();
  }

  if (PlatformUtils.isDesktop) {
    await _init(
      "auto start service",
      () => container.read(autoStartServiceProvider.future),
    );
    await _init(
      "window controller",
      () => container.read(windowControllerProvider.future),
    );
  }

  await _init(
    "sing-box",
    () => container.read(singboxServiceProvider).init(),
  );

  await _safeInit(
    "active profile",
    () => container.read(activeProfileProvider.future),
  );
  await _init(
    "deep link service",
    () => container.read(deepLinkServiceProvider.future),
  );

  if (PlatformUtils.isDesktop) {
    await _safeInit(
      "system tray",
      () => container.read(systemTrayControllerProvider.future),
      timeout: 1000,
    );
  }

  Logger.bootstrap.info("bootstrap took [${stopWatch.elapsedMilliseconds}ms]");
  stopWatch.stop();

  runApp(
    ProviderScope(
      parent: container,
      child: SentryUserInteractionWidget(
        child: const App(),
      ),
    ),
  );

  if (!silentStart) FlutterNativeSplash.remove();
}

Future<T> _init<T>(
  String name,
  Future<T> Function() initializer, {
  int? timeout,
}) async {
  final stopWatch = Stopwatch()..start();
  Future<T> func() => timeout != null
      ? initializer().timeout(Duration(milliseconds: timeout))
      : initializer();
  try {
    final result = await func();
    Logger.bootstrap
        .debug("[$name] initialized in ${stopWatch.elapsedMilliseconds}ms");
    return result;
  } catch (e, stackTrace) {
    Logger.bootstrap.error("[$name] error initializing", e, stackTrace);
    rethrow;
  } finally {
    stopWatch.stop();
  }
}

Future<T?> _safeInit<T>(
  String name,
  Future<T> Function() initializer, {
  int? timeout,
}) async {
  try {
    return await _init(name, initializer, timeout: timeout);
  } catch (_) {
    return null;
  }
}
