import 'package:flutter/material.dart';
import 'package:hiddify/core/prefs/prefs.dart';
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
    const windowOptions = WindowOptions(
      size: size,
      minimumSize: size,
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
