import 'dart:ui';

import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'window_notifier.g.dart';

const minimumWindowSize = Size(368, 568);
const defaultWindowSize = Size(868, 668);

@Riverpod(keepAlive: true)
class WindowNotifier extends _$WindowNotifier with AppLogger {
  @override
  Future<void> build() async {
    if (!PlatformUtils.isDesktop) return;

    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(minimumWindowSize);
    await windowManager.setSize(defaultWindowSize);

    final appInfo = await ref.watch(appInfoProvider.future);
    await windowManager
        .setTitle("${Constants.appName} v${appInfo.presentVersion}");
  }

  Future<void> open({bool focus = true}) async {
    await windowManager.show();
    if (focus) await windowManager.focus();
  }

  // TODO add option to quit or minimize to tray
  Future<void> close() async {
    await windowManager.hide();
  }

  Future<void> quit() async {
    await ref
        .read(connectionNotifierProvider.notifier)
        .abortConnection()
        .timeout(const Duration(seconds: 2))
        .catchError(
      (e) {
        loggy.warning("error aborting connection on quit", e);
      },
    );
    await trayManager.destroy();
    await windowManager.destroy();
  }
}
