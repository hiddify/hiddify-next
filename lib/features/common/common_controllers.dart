import 'package:hiddify/core/prefs/general_prefs.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/features/common/window/window_controller.dart';
import 'package:hiddify/features/profiles/notifier/notifier.dart';
import 'package:hiddify/features/system_tray/system_tray_controller.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'common_controllers.g.dart';

// this is a temporary solution to keep providers running even when there are no active listeners
// https://github.com/rrousselGit/riverpod/discussions/2730
@Riverpod(keepAlive: true)
void commonControllers(CommonControllersRef ref) {
  ref.listen(
    introCompletedProvider,
    (_, completed) async {
      if (completed) {
        await ref.read(cronServiceProvider).startScheduler();
      }
    },
    fireImmediately: true,
  );
  ref.listen(
    connectivityControllerProvider,
    (previous, next) {},
    fireImmediately: true,
  );
  ref.listen(
    profilesUpdateNotifierProvider,
    (previous, next) {},
    fireImmediately: true,
  );
  if (PlatformUtils.isDesktop) {
    ref.listen(
      windowControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    ref.listen(
      systemTrayControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
  }
}
