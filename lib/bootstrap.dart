import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hiddify/core/app/app.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/features/system_tray/system_tray.dart';
import 'package:hiddify/services/deep_link_service.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

final _loggy = Loggy('bootstrap');
final _stopWatch = Stopwatch();

Future<void> lazyBootstrap(WidgetsBinding widgetsBinding) async {
  _stopWatch.start();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // temporary solution: https://github.com/rrousselGit/riverpod/issues/1874
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  Loggy.initLoggy(logPrinter: const PrettyPrinter());

  await initAppServices(container.read);
  await initControllers(container.read);

  runApp(
    ProviderScope(
      parent: container,
      child: const AppView(),
    ),
  );

  FlutterNativeSplash.remove();
  _stopWatch.stop();
  _loggy.debug("bootstrapping took [${_stopWatch.elapsedMilliseconds}]ms");
}

Future<void> initAppServices(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await read(filesEditorServiceProvider).init();
  await Future.wait(
    [
      read(connectivityServiceProvider).init(),
      read(clashServiceProvider).init(),
      read(clashServiceProvider).start(),
      read(notificationServiceProvider).init(),
      if (PlatformUtils.isDesktop) read(windowManagerServiceProvider).init(),
    ],
  );
  _loggy.debug('initialized app services');
}

Future<void> initControllers(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await Future.wait(
    [
      read(activeProfileProvider.future),
      read(deepLinkServiceProvider.future),
      if (PlatformUtils.isDesktop) read(systemTrayControllerProvider.future),
    ],
  );
  _loggy.debug("initialized base controllers");
}
