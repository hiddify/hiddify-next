import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/features/common/clash/clash_mode.dart';
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
      await trayManager.setIcon(Assets.images.trayIcon);
      trayManager.addListener(this);
      _initialized = true;
    }

    final connection = await ref.watch(connectivityControllerProvider.future);
    final mode =
        ref.watch(clashModeProvider.select((value) => value.valueOrNull));

    loggy.debug('updating system tray');
    await _updateTray(connection, mode);
  }

  bool _initialized = false;

  Future<void> _updateTray(
    ConnectionStatus connection,
    TunnelMode? mode,
  ) async {
    final t = ref.watch(translationsProvider);
    final trayMenu = Menu(
      items: [
        MenuItem(
          label: t.tray.dashboard,
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
    await ref.read(connectivityControllerProvider.notifier).abortConnection();
    await trayManager.destroy();
    return ref.read(windowControllerProvider.notifier).quit();
  }
}
