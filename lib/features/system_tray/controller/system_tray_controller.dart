import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/features/common/clash/clash_mode.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'system_tray_controller.g.dart';

// TODO: rewrite
@Riverpod(keepAlive: true)
class SystemTrayController extends _$SystemTrayController
    with TrayListener, AppLogger {
  @override
  Future<void> build() async {
    await trayManager.setIcon(Assets.images.logoRound);
    trayManager.addListener(this);
    ref.onDispose(() {
      loggy.debug('disposing');
      trayManager.removeListener(this);
    });
    ref.listen(
      connectivityControllerProvider,
      (_, next) async {
        connection = next;
        await _updateTray();
      },
      fireImmediately: true,
    );
    ref.listen(
      clashModeProvider.select((value) => value.valueOrNull),
      (_, next) async {
        mode = next;
        await _updateTray();
      },
      fireImmediately: true,
    );
  }

  late ConnectionStatus connection;
  late TunnelMode? mode;

  Future<void> _updateTray() async {
    final t = ref.watch(translationsProvider);
    final isVisible = await windowManager.isVisible();
    final trayMenu = Menu(
      items: [
        MenuItem.checkbox(
          label: t.tray.dashboard,
          checked: isVisible,
          onClick: handleClickShowApp,
        ),
        if (mode != null) ...[
          MenuItem.separator(),
          ...TunnelMode.values.map(
            (e) => MenuItem.checkbox(
              label: e.name,
              checked: e == mode,
              onClick: (mi) => handleClickModeItem(e, mi),
            ),
          ),
        ],
        MenuItem.separator(),
        MenuItem.checkbox(
          label: t.tray.systemProxy,
          checked: connection.isConnected,
          disabled: connection.isSwitching,
          onClick: handleClickSetAsSystemProxy,
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

  @override
  Future<void> onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseDown();
    await trayManager.popUpContextMenu();
  }

  Future<void> handleClickShowApp(MenuItem menuItem) async {
    if (menuItem.checked == true) {
      await windowManager.close();
    } else {
      await windowManager.show();
    }
  }

  Future<void> handleClickModeItem(
    TunnelMode mode,
    MenuItem menuItem,
  ) async {
    return ref
        .read(prefsControllerProvider.notifier)
        .patchClashOverrides(ClashConfigPatch(mode: some(mode)));
  }

  Future<void> handleClickSetAsSystemProxy(MenuItem menuItem) async {
    return ref.read(connectivityControllerProvider.notifier).toggleConnection();
  }

  Future<void> handleClickExitApp(MenuItem menuItem) async {
    exit(0);
  }
}
