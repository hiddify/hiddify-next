import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:ffi/ffi.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/gen/singbox_generated_bindings.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart' as p;

final _logger = Loggy('FFISingboxService');

class FFISingboxService with InfraLogger implements SingboxService {
  static final SingboxNativeLibrary _box = _gen();

  Stream<String>? _statusStream;

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
  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
  ) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          _box.setup(
            baseDir.toNativeUtf8().cast(),
            workingDir.toNativeUtf8().cast(),
            tempDir.toNativeUtf8().cast(),
          );
          _box.setupOnce(NativeApi.initializeApiDLData);
          return right(unit);
        },
      ),
    );
  }

  @override
  TaskEither<String, Unit> parseConfig(String path) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .parse(path.toNativeUtf8().cast())
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
  TaskEither<String, Unit> create(String configPath) {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box
              .create(configPath.toNativeUtf8().cast())
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
  TaskEither<String, Unit> start() {
    return TaskEither(
      () => CombineWorker().execute(
        () {
          final err = _box.start().cast<Utf8>().toDartString();
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
  Stream<String> watchStatus() {
    if (_statusStream != null) return _statusStream!;
    final receiver = ReceivePort('status receiver');
    final statusStream = receiver.asBroadcastStream(
      onCancel: (_) {
        _logger.debug("stopping status command client");
        final err = _box.stopCommandClient(1).cast<Utf8>().toDartString();
        if (err.isNotEmpty) {
          _logger.warning("error stopping status client");
        }
        receiver.close();
        _statusStream = null;
      },
    ).map(
      (event) {
        if (event case String _) {
          if (event.startsWith('error:')) {
            loggy.warning("[status client] error received: $event");
            throw event.replaceFirst('error:', "");
          }
          return event;
        }
        loggy.warning("[status client] unexpected type, msg: $event");
        throw "invalid type";
      },
    );

    final err = _box
        .startCommandClient(1, receiver.sendPort.nativePort)
        .cast<Utf8>()
        .toDartString();
    if (err.isNotEmpty) {
      loggy.warning("error starting status command: $err");
      throw err;
    }

    return _statusStream = statusStream;
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
