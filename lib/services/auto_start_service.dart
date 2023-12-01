import 'dart:io';

import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_start_service.g.dart';

@Riverpod(keepAlive: true)
class AutoStartService extends _$AutoStartService with InfraLogger {
  @override
  Future<bool> build() async {
    loggy.debug("initializing");
    if (!PlatformUtils.isDesktop) return false;
    final appInfo = ref.watch(appInfoProvider).requireValue;
    launchAtStartup.setup(
      appName: appInfo.name,
      appPath: Platform.resolvedExecutable,
    );
    final isEnabled = await launchAtStartup.isEnabled();
    loggy.info("auto start is [${isEnabled ? "Enabled" : "Disabled"}]");
    return isEnabled;
  }

  Future<void> enable() async {
    loggy.debug("enabling auto start");
    await launchAtStartup.enable();
    state = const AsyncValue.data(true);
  }

  Future<void> disable() async {
    loggy.debug("disabling auto start");
    await launchAtStartup.disable();
    state = const AsyncValue.data(false);
  }
}
