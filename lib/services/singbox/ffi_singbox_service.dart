import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:ffi/ffi.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/gen/singbox_generated_bindings.dart';
import 'package:hiddify/services/singbox/shared.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:watcher/watcher.dart';

final _logger = Loggy('FFISingboxService');

class FFISingboxService
    with ServiceStatus, InfraLogger
    implements SingboxService {
  static final SingboxNativeLibrary _box = _gen();

  late final ValueStream<ConnectionStatus> _connectionStatus;
  late final ReceivePort _connectionStatusReceiver;
  Stream<String>? _serviceStatsStream;
  Stream<String>? _outboundsStream;

  static SingboxNativeLibrary _gen() {
    String fullPath = "";
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      fullPath = "libcore";
    }
    if (Platform.isWindows) {
      fullPath = p.join(fullPath, "libcore.dll");
    } else if (Platform.isMacOS) {
      fullPath = p.join(fullPath, "libcore.dylib");
    } else {
      fullPath = p.join(fullPath, "libcore.so");
    }
    _logger.debug('singbox native libs path: "$fullPath"');
    final lib = DynamicLibrary.open(fullPath);
    return SingboxNativeLibrary(lib);
  }

  @override
  Future<void> init() async {
    loggy.debug("initializing");
    _connectionStatusReceiver = ReceivePort('service status receiver');
    final source = _connectionStatusReceiver
        .asBroadcastStream()
        .map((event) => jsonDecode(event as String) as Map<String, dynamic>)
        .map(mapEventToStatus);
    _connectionStatus = ValueConnectableStream.seeded(
      source,
      const ConnectionStatus.disconnected(),
    ).autoConnect();
  }

  @override
  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
    bool debug,
  ) {
    final port = _connectionStatusReceiver.sendPort.nativePort;
    return TaskEither(
      () => CombineWorker().execute(
        () {
          _box.setupOnce(NativeApi.initializeApiDLData);
          final err = _box
              .setup(
                baseDir.toNativeUtf8().cast(),
                workingDir.toNativeUtf8().cast(),
                tempDir.toNativeUtf8().cast(),
                port,
                debug ? 1 : 0,
              )
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> parseConfig(
    String path,
    String tempPath,
    bool debug,
  ) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .parse(
                path.toNativeUtf8().cast(),
                tempPath.toNativeUtf8().cast(),
                debug ? 1 : 0,
              )
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> changeConfigOptions(ConfigOptions options) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final json = jsonEncode(options.toJson());
          final err = _box
              .changeConfigOptions(json.toNativeUtf8().cast())
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, String> generateConfig(
    String path,
  ) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final response = _box
              .generateConfig(
                path.toNativeUtf8().cast(),
              )
              .cast<Utf8>()
              .toDartString();
          if (response.startsWith("error")) {
            return left(response.replaceFirst("error", ""));
          }
          return right(response);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> start(String configPath, bool disableMemoryLimit) {
    loggy.debug("starting, memory limit: [${!disableMemoryLimit}]");
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .start(
                configPath.toNativeUtf8().cast(),
                disableMemoryLimit ? 1 : 0,
              )
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> stop() {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box.stop().cast<Utf8>().toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> restart(String configPath, bool disableMemoryLimit) {
    loggy.debug("restarting, memory limit: [${!disableMemoryLimit}]");
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .restart(
                configPath.toNativeUtf8().cast(),
                disableMemoryLimit ? 1 : 0,
              )
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() => _connectionStatus;

  @override
  Stream<String> watchStats() {
    if (_serviceStatsStream != null) return _serviceStatsStream!;
    final receiver = ReceivePort('service stats receiver');
    final statusStream = receiver.asBroadcastStream(
      onCancel: (_) {
        _logger.debug("stopping stats command client");
        final err = _box.stopCommandClient(1).cast<Utf8>().toDartString();
        if (err.isNotEmpty) {
          _logger.error("error stopping stats client");
        }
        receiver.close();
        _serviceStatsStream = null;
      },
    ).map(
      (event) {
        if (event case String _) {
          if (event.startsWith('error:')) {
            loggy.error("[service stats client] error received: $event");
            throw event.replaceFirst('error:', "");
          }
          return event;
        }
        loggy.error("[service status client] unexpected type, msg: $event");
        throw "invalid type";
      },
    );

    final err = _box
        .startCommandClient(1, receiver.sendPort.nativePort)
        .cast<Utf8>()
        .toDartString();
    if (err.isNotEmpty) {
      loggy.error("error starting status command: $err");
      throw err;
    }

    return _serviceStatsStream = statusStream;
  }

  @override
  Stream<String> watchOutbounds() {
    if (_outboundsStream != null) return _outboundsStream!;
    final receiver = ReceivePort('outbounds receiver');
    final outboundsStream = receiver.asBroadcastStream(
      onCancel: (_) {
        _logger.debug("stopping group command client");
        final err = _box.stopCommandClient(4).cast<Utf8>().toDartString();
        if (err.isNotEmpty) {
          _logger.error("error stopping group client");
        }
        receiver.close();
        _outboundsStream = null;
      },
    ).map(
      (event) {
        if (event case String _) {
          if (event.startsWith('error:')) {
            loggy.error("[group client] error received: $event");
            throw event.replaceFirst('error:', "");
          }
          return event;
        }
        loggy.error("[group client] unexpected type, msg: $event");
        throw "invalid type";
      },
    );

    final err = _box
        .startCommandClient(4, receiver.sendPort.nativePort)
        .cast<Utf8>()
        .toDartString();
    if (err.isNotEmpty) {
      loggy.error("error starting group command: $err");
      throw err;
    }

    return _outboundsStream = outboundsStream;
  }

  @override
  TaskEither<String, Unit> selectOutbound(String groupTag, String outboundTag) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .selectOutbound(
                groupTag.toNativeUtf8().cast(),
                outboundTag.toNativeUtf8().cast(),
              )
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> urlTest(String groupTag) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .urlTest(groupTag.toNativeUtf8().cast())
              .cast<Utf8>()
              .toDartString();
          if (err.isNotEmpty) {
            return left(err);
          }
          return right(unit);
        },
      ),
    );
  }

  final _logBuffer = <String>[];
  int _logFilePosition = 0;

  @override
  Stream<List<String>> watchLogs(String path) async* {
    yield await _readLogFile(File(path));
    yield* Watcher(path, pollingDelay: const Duration(seconds: 1))
        .events
        .asyncMap((event) async {
      if (event.type == ChangeType.MODIFY) {
        await _readLogFile(File(path));
      }
      return _logBuffer;
    });
  }

  @override
  TaskEither<String, Unit> clearLogs() {
    return TaskEither(
      () async {
        _logBuffer.clear();
        return right(unit);
      },
    );
  }

  Future<List<String>> _readLogFile(File file) async {
    if (_logFilePosition == 0 && file.lengthSync() == 0) return [];
    final content =
        await file.openRead(_logFilePosition).transform(utf8.decoder).join();
    _logFilePosition = file.lengthSync();
    final lines = const LineSplitter().convert(content);
    if (lines.length > 300) {
      lines.removeRange(0, lines.length - 300);
    }
    for (final line in lines) {
      _logBuffer.add(line);
      if (_logBuffer.length > 300) {
        _logBuffer.removeAt(0);
      }
    }
    return _logBuffer;
  }
}
