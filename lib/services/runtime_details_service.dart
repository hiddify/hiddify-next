import 'dart:io';

import 'package:hiddify/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RuntimeDetailsService with InfraLogger {
  late final PackageInfo packageInfo;

  String get appVersion => packageInfo.version;
  String get buildNumber => packageInfo.buildNumber;

  late final String operatingSystem = Platform.operatingSystem;
  late final String userAgent;

  Future<void> init() async {
    loggy.debug("initializing");
    packageInfo = await PackageInfo.fromPlatform();
    userAgent = "HiddifyNext/$appVersion ($operatingSystem)";

    loggy.info(
      "os: [$operatingSystem](${Platform.operatingSystemVersion}), processor count [${Platform.numberOfProcessors}]",
    );
  }
}
