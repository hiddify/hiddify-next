import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/window/notifier/window_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';

part 'system_tray_notifier.g.dart';

@Riverpod(keepAlive: true)
class SystemTrayNotifier extends _$SystemTrayNotifier with AppLogger {
  @override
  Future<void> build() async {
    if (!PlatformUtils.isDesktop) return;

    await trayManager.setIcon(
      _trayIconPath,
      isTemplate: Platform.isMacOS,
    );
    if (!Platform.isLinux) await trayManager.setToolTip(Constants.appName);

    ConnectionStatus connection;
    try {
      connection = await ref.watch(connectionNotifierProvider.future);
    } catch (e) {
      loggy.warning("error getting connection status", e);
      connection = const ConnectionStatus.disconnected();
    }

    final serviceMode = ref.watch(ConfigOptions.serviceMode);

    final t = ref.watch(translationsProvider);
    final destinations = <(String label, String location)>[
      (t.home.pageTitle, const HomeRoute().location),
      (t.proxies.pageTitle, const ProxiesRoute().location),
      (t.logs.pageTitle, const LogsOverviewRoute().location),
      (t.settings.pageTitle, const SettingsRoute().location),
      (t.about.pageTitle, const AboutRoute().location),
    ];

    loggy.debug('updating system tray');

    final menu = Menu(
      items: [
        MenuItem(
          label: t.tray.dashboard,
          onClick: (_) async {
            await ref.read(windowNotifierProvider.notifier).open();
          },
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
          onClick: (_) async {
            await ref
                .read(connectionNotifierProvider.notifier)
                .toggleConnection();
          },
        ),
        MenuItem.submenu(
          label: t.config.serviceMode,
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
                        .read(ConfigOptions.serviceMode.notifier)
                        .update(newMode);
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
                    await ref.read(windowNotifierProvider.notifier).open();
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
          onClick: (_) async {
            return ref.read(windowNotifierProvider.notifier).quit();
          },
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  static String get _trayIconPath {
    if (Platform.isWindows) {
      final Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      if (isDarkMode) {
        return Assets.images.trayIconIco;
      } else {
        return Assets.images.trayIconDarkIco;
      }
    }
    
    return Assets.images.trayIconPng.path;
  }
}
