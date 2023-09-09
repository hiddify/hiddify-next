import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/utils/utils.dart';

class PlatformSettings with InfraLogger {
  late final MethodChannel _methodChannel =
      const MethodChannel("com.hiddify.app/platform.settings");

  TaskEither<String, bool> isIgnoringBatteryOptimizations() {
    return TaskEither(
      () async {
        loggy.debug("checking battery optimization status");
        final result = await _methodChannel
            .invokeMethod<bool>("is_ignoring_battery_optimizations");
        loggy.debug("is ignoring battery optimizations? [$result]");
        return right(result!);
      },
    );
  }

  TaskEither<String, bool> requestIgnoreBatteryOptimizations() {
    return TaskEither(
      () async {
        loggy.debug("requesting ignore battery optimization");
        final result = await _methodChannel
            .invokeMethod<bool>("request_ignore_battery_optimizations");
        loggy.debug("ignore battery optimization result: [$result]");
        return right(result!);
      },
    );
  }
}
