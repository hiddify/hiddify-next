import 'dart:io';

import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/data/repository/config_options_store.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/features/common/window/window_controller.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';

part 'system_tray_controller.g.dart';

@Riverpod(keepAlive: true)
class SystemTrayController extends _$SystemTrayController
    with TrayListener, AppLogger {
  @override
  Future<void> build() async {
    if (!_initialized) {
      loggy.debug('initializing');
      await trayManager.setIcon(
        _trayIconPath,
        isTemplate: Platform.isMacOS,
      );
      if (!Platform.isLinux) await trayManager.setToolTip(Constants.appName);
      trayManager.addListener(this);
      _initialized = true;
    }

    final connection = switch (ref.watch(connectivityControllerProvider)) {
      AsyncData(:final value) => value,
      _ => const Disconnected(),
    };
    final serviceMode = ref.watch(serviceModeStoreProvider);

    final t = ref.watch(translationsProvider);

    loggy.debug('updating system tray');

    final trayMenu = Menu(
      items: [
        MenuItem(
          label: t.tray.dashboard,
          onClick: handleClickShowApp,
        ),
        MenuItem.separator(),
        MenuItem.checkbox(
          label: switch (connection) {
            Disconnected() => t.tray.status.connect,
            Connecting() => t.tray.status.connecting,
            Connected() => t.tray.status.disconnect,
            Disconnecting() => t.tray.status.disconnecting,
          },
          checked: connection.isConnected,
          disabled: connection.isSwitching,
          onClick: handleClickSetAsSystemProxy,
        ),
        MenuItem.submenu(
          label: t.settings.config.serviceMode,
          submenu: Menu(
            items: [
              ...ServiceMode.values.map(
                (e) => MenuItem.checkbox(
                  checked: e == serviceMode,
                  key: e.name,
                  label: e.present(t),
                  onClick: (menuItem) async {
                    final newMode = ServiceMode.values.byName(menuItem.key!);
                    loggy.debug("switching service mode: [$newMode]");
                    await ref
                        .read(serviceModeStoreProvider.notifier)
                        .update(newMode);
                  },
                ),
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem(
          label: t.tray.quit,
          onClick: handleClickExitApp,
        ),
      ],
    );
    await trayManager.setContextMenu(trayMenu);
  }

  bool _initialized = false;

  String get _trayIconPath {
    if (Platform.isWindows) return Assets.images.trayIconIco;
    return Assets.images.trayIconPng.path;
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    await ref.read(windowControllerProvider.notifier).show();
  }

  @override
  Future<void> onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseDown();
    await trayManager.popUpContextMenu();
  }

  Future<void> handleClickShowApp(MenuItem menuItem) async {
    if (await ref.read(windowControllerProvider.future)) return;
    await ref.read(windowControllerProvider.notifier).show();
  }

  Future<void> handleClickSetAsSystemProxy(MenuItem menuItem) async {
    return ref.read(connectivityControllerProvider.notifier).toggleConnection();
  }

  Future<void> handleClickExitApp(MenuItem menuItem) async {
    await ref.read(connectivityControllerProvider.notifier).abortConnection();
    await trayManager.destroy();
    return ref.read(windowControllerProvider.notifier).quit();
  }
}
