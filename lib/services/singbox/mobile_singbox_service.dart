import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';

class MobileSingboxService with InfraLogger implements SingboxService {
  late final MethodChannel _methodChannel =
      const MethodChannel("com.hiddify.app/method");
  late final EventChannel _logsChannel =
      const EventChannel("com.hiddify.app/service.logs");

  @override
  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
  ) =>
      TaskEither.of(unit);

  @override
  TaskEither<String, Unit> parseConfig(String path) {
    return TaskEither(
      () async {
        final message = await _methodChannel.invokeMethod<String>(
          "parse_config",
          {"path": path},
        );
        if (message == null || message.isEmpty) return right(unit);
        return left(message);
      },
    );
  }

  @override
  TaskEither<String, Unit> create(String configPath) {
    return TaskEither(
      () async {
        loggy.debug("creating service for: $configPath");
        await _methodChannel.invokeMethod(
          "set_active_config_path",
          {"path": configPath},
        );
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, Unit> start() {
    return TaskEither(
      () async {
        loggy.debug("starting");
        await _methodChannel.invokeMethod("start");
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, Unit> stop() {
    return TaskEither(
      () async {
        loggy.debug("stopping");
        await _methodChannel.invokeMethod("stop");
        return right(unit);
      },
    );
  }

  @override
  Stream<String> watchLogs(String path) {
    return _logsChannel.receiveBroadcastStream().map(
      (event) {
        loggy.debug("received log: $event");
        return event as String;
      },
    );
  }
}
