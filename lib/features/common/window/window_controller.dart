import 'package:flutter/material.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/service_preferences.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'window_controller.g.dart';

// TODO improve
@Riverpod(keepAlive: true)
class WindowController extends _$WindowController
    with WindowListener, AppLogger {
  @override
  Future<bool> build() async {
    await windowManager.ensureInitialized();
    const size = Size(868, 668);
    const minimumSize = Size(368, 568);
    const windowOptions = WindowOptions(
      size: size,
      minimumSize: minimumSize,
      center: true,
    );
    await windowManager.setPreventClose(true);
    await windowManager.waitUntilReadyToShow(
      windowOptions,
      () async {
        if (ref.read(silentStartNotifierProvider)) {
          loggy.debug("silent start is enabled, hiding window");
          await windowManager.hide();
        }
        await Future.delayed(
          const Duration(seconds: 3),
          () async {
            if (ref.read(startedByUserProvider)) {
              loggy.debug("previously started by user, trying to connect");
              return ref.read(connectionNotifierProvider.notifier).mayConnect();
            }
          },
        );
      },
    );
    windowManager.addListener(this);

    ref.onDispose(() {
      loggy.debug("disposing");
      windowManager.removeListener(this);
    });
    return windowManager.isVisible();
  }

  Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
    state = const AsyncData(true);
  }

  Future<void> hide() async {
    await windowManager.close();
  }

  Future<void> quit() async {
    loggy.debug("quitting");
    await windowManager.close();
    await windowManager.destroy();
  }

  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
    state = const AsyncData(false);
  }
}
