import 'dart:io';

import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/window/window_controller.dart';
import 'package:hiddify/features/config_option/model/config_option_patch.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
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

    final connection = switch (ref.watch(connectionNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => const Disconnected(),
    };
    final serviceMode = await ref
        .watch(configOptionNotifierProvider.future)
        .then((value) => value.serviceMode);

    final t = ref.watch(translationsProvider);
    final destinations = <(String label, String location)>[
      (t.home.pageTitle, const HomeRoute().location),
      (t.proxies.pageTitle, const ProxiesRoute().location),
      (t.logs.pageTitle, const LogsOverviewRoute().location),
      (t.settings.pageTitle, const SettingsRoute().location),
      (t.about.pageTitle, const AboutRoute().location),
    ];

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
                        .read(configOptionNotifierProvider.notifier)
                        .updateOption(ConfigOptionPatch(serviceMode: newMode));
                  },
                ),
              ),
            ],
          ),
        ),
        MenuItem.submenu(
          label: t.tray.open,
          submenu: Menu(
            items: [
              ...destinations.map(
                (e) => MenuItem(
                  label: e.$1,
                  onClick: (_) async {
                    await ref.read(windowControllerProvider.notifier).show();
                    ref.read(routerProvider).go(e.$2);
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
    if (Platform.isMacOS) {
      await trayManager.popUpContextMenu();
    } else {
      await ref.read(windowControllerProvider.notifier).show();
    }
  }

  @override
  Future<void> onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseDown();
    await trayManager.popUpContextMenu();
  }

  Future<void> handleClickShowApp(MenuItem menuItem) async {
    await ref.read(windowControllerProvider.notifier).show();
  }

  Future<void> handleClickSetAsSystemProxy(MenuItem menuItem) async {
    return ref.read(connectionNotifierProvider.notifier).toggleConnection();
  }

  Future<void> handleClickExitApp(MenuItem menuItem) async {
    await ref.read(connectionNotifierProvider.notifier).abortConnection();
    await trayManager.destroy();
    return ref.read(windowControllerProvider.notifier).quit();
  }
}
