import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:combine/combine.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/gen/singbox_generated_bindings.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;

class FFISingboxService with InfraLogger implements SingboxService {
  static final SingboxNativeLibrary _box = _gen();

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
    debugPrint('singbox native libs path: "$fullPath"');
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
