import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:ffi/ffi.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/singbox/config_options.dart';
import 'package:hiddify/gen/singbox_generated_bindings.dart';
import 'package:hiddify/services/singbox/shared.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

final _logger = Loggy('FFISingboxService');

class FFISingboxService
    with ServiceStatus, InfraLogger
    implements SingboxService {
  static final SingboxNativeLibrary _box = _gen();

  late final ValueStream<ConnectionStatus> _connectionStatus;
  late final ReceivePort _connectionStatusReceiver;
  Stream<String>? _statusStream;
  Stream<String>? _groupsStream;

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
  ) {
    final port = _connectionStatusReceiver.sendPort.nativePort;
    return TaskEither(
      () => CombineWorker().execute(
        () {
          _box.setupOnce(NativeApi.initializeApiDLData);
          _box.setup(
            baseDir.toNativeUtf8().cast(),
            workingDir.toNativeUtf8().cast(),
            tempDir.toNativeUtf8().cast(),
            port,
          );
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
  TaskEither<String, Unit> start(String configPath) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .start(configPath.toNativeUtf8().cast())
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
  TaskEither<String, Unit> restart(String configPath) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .restart(configPath.toNativeUtf8().cast())
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
    if (_statusStream != null) return _statusStream!;
    final receiver = ReceivePort('status receiver');
    final statusStream = receiver.asBroadcastStream(
      onCancel: (_) {
        _logger.debug("stopping status command client");
        final err = _box.stopCommandClient(1).cast<Utf8>().toDartString();
        if (err.isNotEmpty) {
          _logger.error("error stopping status client");
        }
        receiver.close();
        _statusStream = null;
      },
    ).map(
      (event) {
        if (event case String _) {
          if (event.startsWith('error:')) {
            loggy.error("[status client] error received: $event");
            throw event.replaceFirst('error:', "");
          }
          return event;
        }
        loggy.error("[status client] unexpected type, msg: $event");
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

    return _statusStream = statusStream;
  }

  @override
  Stream<String> watchOutbounds() {
    if (_groupsStream != null) return _groupsStream!;
    final receiver = ReceivePort('outbounds receiver');
    final groupsStream = receiver.asBroadcastStream(
      onCancel: (_) {
        _logger.debug("stopping group command client");
        final err = _box.stopCommandClient(4).cast<Utf8>().toDartString();
        if (err.isNotEmpty) {
          _logger.error("error stopping group client");
        }
        receiver.close();
        _groupsStream = null;
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

    return _groupsStream = groupsStream;
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

  @override
  Stream<String> watchLogs(String path) {
    var linesRead = 0;
    return Stream.periodic(
      const Duration(seconds: 1),
    ).asyncMap((_) async {
      final result = await _readLogs(path, linesRead);
      linesRead = result.$2;
      return result.$1;
    }).transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final item in data) {
            sink.add(item);
          }
        },
      ),
    );
  }

  Future<(List<String>, int)> _readLogs(String path, int from) async {
    return CombineWorker().execute(
      () async {
        final lines = await File(path).readAsLines();
        final to = lines.length;
        return (lines.sublist(from), to);
      },
    );
  }
}
