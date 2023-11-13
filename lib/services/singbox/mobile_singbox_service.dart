import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connection_status.dart';
import 'package:hiddify/domain/singbox/config_options.dart';
import 'package:hiddify/services/singbox/shared.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class MobileSingboxService
    with ServiceStatus, InfraLogger
    implements SingboxService {
  late final _methodChannel = const MethodChannel("com.hiddify.app/method");
  late final _connectionStatusChannel =
      const EventChannel("com.hiddify.app/service.status");
  late final _alertsChannel =
      const EventChannel("com.hiddify.app/service.alerts");
  late final _logsChannel = const EventChannel("com.hiddify.app/service.logs");

  late final ValueStream<ConnectionStatus> _connectionStatus;

  @override
  Future<void> init() async {
    loggy.debug("initializing");
    final status =
        _connectionStatusChannel.receiveBroadcastStream().map(mapEventToStatus);
    final alerts =
        _alertsChannel.receiveBroadcastStream().map(mapEventToStatus);
    _connectionStatus =
        ValueConnectableStream(Rx.merge([status, alerts])).autoConnect();
    await _connectionStatus.first;
  }

  @override
  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
    bool debug,
  ) =>
      TaskEither.of(unit);

  @override
  TaskEither<String, Unit> parseConfig(
    String path,
    String tempPath,
    bool debug,
  ) {
    return TaskEither(
      () async {
        final message = await _methodChannel.invokeMethod<String>(
          "parse_config",
          {"path": path, "tempPath": tempPath, "debug": debug},
        );
        if (message == null || message.isEmpty) return right(unit);
        return left(message);
      },
    );
  }

  @override
  TaskEither<String, Unit> changeConfigOptions(ConfigOptions options) {
    return TaskEither(
      () async {
        await _methodChannel.invokeMethod(
          "change_config_options",
          jsonEncode(options.toJson()),
        );
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, String> generateConfig(
    String path,
  ) {
    return TaskEither(
      () async {
        final configJson = await _methodChannel.invokeMethod<String>(
          "generate_config",
          {"path": path},
        );
        if (configJson == null || configJson.isEmpty) {
          return left("null response");
        }
        return right(configJson);
      },
    );
  }

  @override
  TaskEither<String, Unit> start(String configPath, bool disableMemoryLimit) {
    return TaskEither(
      () async {
        loggy.debug("starting");
        await _methodChannel.invokeMethod(
          "start",
          {"path": configPath},
        );
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
  TaskEither<String, Unit> restart(String configPath, bool disableMemoryLimit) {
    return TaskEither(
      () async {
        loggy.debug("restarting");
        await _methodChannel.invokeMethod(
          "restart",
          {"path": configPath},
        );
        return right(unit);
      },
    );
  }

  @override
  Stream<String> watchOutbounds() {
    const channel = EventChannel("com.hiddify.app/groups");
    loggy.debug("watching outbounds");
    return channel.receiveBroadcastStream().map(
      (event) {
        if (event case String _) {
          return event;
        }
        loggy.error("[group client] unexpected type, msg: $event");
        throw "invalid type";
      },
    );
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() => _connectionStatus;

  @override
  Stream<String> watchStats() {
    // TODO: implement watchStatus
    return const Stream.empty();
  }

  @override
  TaskEither<String, Unit> selectOutbound(String groupTag, String outboundTag) {
    return TaskEither(
      () async {
        loggy.debug("selecting outbound");
        await _methodChannel.invokeMethod(
          "select_outbound",
          {"groupTag": groupTag, "outboundTag": outboundTag},
        );
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, Unit> urlTest(String groupTag) {
    return TaskEither(
      () async {
        await _methodChannel.invokeMethod(
          "url_test",
          {"groupTag": groupTag},
        );
        return right(unit);
      },
    );
  }

  @override
  Stream<List<String>> watchLogs(String path) async* {
    yield* _logsChannel
        .receiveBroadcastStream()
        .map((event) => (event as List).map((e) => e as String).toList());
  }

  @override
  TaskEither<String, Unit> clearLogs() {
    return TaskEither(
      () async {
        await _methodChannel.invokeMethod("clear_logs");
        return right(unit);
      },
    );
  }
}
