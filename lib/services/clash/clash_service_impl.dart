import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:ffi/ffi.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/gen/clash_generated_bindings.dart';
import 'package:hiddify/services/clash/async_ffi.dart';
import 'package:hiddify/services/clash/clash_service.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

// TODO: logging has potential memory leak
class ClashServiceImpl with AsyncFFI, InfraLogger implements ClashService {
  ClashServiceImpl({required this.filesEditor});

  final FilesEditorService filesEditor;

  late final ClashNativeLibrary _clash;

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    _initClashLib();
    _clash.initNativeDartBridge(NativeApi.initializeApiDLData);
  }

  void _initClashLib() {
    String fullPath = "";
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      fullPath = "core";
    }
    if (Platform.isWindows) {
      fullPath = p.join(fullPath, "libclash.dll");
    } else if (Platform.isMacOS) {
      fullPath = p.join(fullPath, "libclash.dylib");
    } else {
      fullPath = p.join(fullPath, "libclash.so");
    }
    loggy.debug('clash native libs path: "$fullPath"');
    final lib = DynamicLibrary.open(fullPath);
    _clash = ClashNativeLibrary(lib);
  }

  @override
  Future<void> start({String configFileName = "config"}) async {
    loggy.debug('starting clash with config: [$configFileName]');
    final stopWatch = Stopwatch()..start();
    final configPath = filesEditor.configPath(configFileName);
    final response = await runAsync(
      (port) => _clash.setOptions(
        port,
        filesEditor.clashDirPath.toNativeUtf8().cast(),
        configPath.toNativeUtf8().cast(),
      ),
    );
    if (!response.success) throw ClashFailure.core(response.message);
    stopWatch.stop();
    loggy.info(
      "started clash service [${stopWatch.elapsedMilliseconds}ms]",
    );
  }

  @override
  TaskEither<String, bool> validateConfig(String configPath) {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) =>
              _clash.validateConfig(port, configPath.toNativeUtf8().cast()),
        );
        if (!response.success) return left(response.message ?? '');
        return right(response.data! == "true");
      },
    );
  }

  @override
  TaskEither<String, Unit> updateConfigs(String path) {
    return TaskEither(() async {
      final stopWatch = Stopwatch()..start();
      final response = await runAsync(
        (port) => _clash.updateConfigs(port, path.toNativeUtf8().cast(), 0),
      );
      stopWatch.stop();
      if (response.success) {
        loggy.info("changed config in [${stopWatch.elapsedMilliseconds}ms]");
        return right(unit);
      }
      return left(response.message ?? '');
    });
  }

  @override
  TaskEither<String, List<ClashProxy>> getProxies() {
    return TaskEither(
      () async {
        final response = await runAsync((port) => _clash.getProxies(port));
        if (!response.success) return left(response.message ?? "");
        final proxies = await CombineWorker().executeWithArg(
          (data) {
            if (data == null) return <ClashProxy>[];
            final json = jsonDecode(data)['proxies'] as Map<String, dynamic>;
            final parsed = json.entries.map(
              (e) {
                final proxyMap = (e.value as Map<String, dynamic>)
                  ..putIfAbsent('name', () => e.key);
                return ClashProxy.fromJson(proxyMap);
              },
            ).toList();
            return parsed;
          },
          response.data,
        );
        return right(proxies);
      },
    );
  }

  @override
  TaskEither<String, Unit> patchConfigs(ClashConfig config) {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) => _clash.patchConfigs(
            port,
            jsonEncode(config.toJson()).toNativeUtf8().cast(),
          ),
        );
        if (!response.success) return left(response.message ?? "");
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, ClashConfig> getConfigs() {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) => _clash.getConfigs(port),
        );
        if (!response.success) return left(response.message ?? "");
        return right(
          ClashConfig.fromJson(
            jsonDecode(response.data!) as Map<String, dynamic>,
          ),
        );
      },
    );
  }

  @override
  TaskEither<String, Unit> changeProxy(
    String selectorName,
    String proxyName,
  ) {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) => _clash.updateProxy(
            port,
            selectorName.toNativeUtf8().cast(),
            proxyName.toNativeUtf8().cast(),
          ),
        );
        if (!response.success) return left(response.message ?? "");
        return right(unit);
      },
    );
  }

  @override
  TaskEither<String, int> getProxyDelay(
    String name,
    String url, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) => _clash.getProxyDelay(
            port,
            name.toNativeUtf8().cast(),
            url.toNativeUtf8().cast(),
            timeout.inMilliseconds,
          ),
        );
        if (!response.success) return left(response.message ?? "");
        return right(
          (jsonDecode(response.data!) as Map<String, dynamic>)["delay"] as int,
        );
      },
    );
  }

  @override
  Stream<ClashLog> watchLogs(LogLevel level) {
    final logsPort = ReceivePort();
    final logsStream = logsPort.map(
      (event) {
        final json = jsonDecode(event as String) as Map<String, dynamic>;
        return ClashLog.fromJson(json);
      },
    );
    _clash.startLog(
      logsPort.sendPort.nativePort,
      level.name.toNativeUtf8().cast(),
    );
    return logsStream.doOnCancel(() => _clash.stopLog());
  }

  @override
  TaskEither<String, ClashTraffic> getTraffic() {
    return TaskEither(
      () async {
        final response = await runAsync(
          (port) => _clash.getTraffic(port),
        );
        if (!response.success) return left(response.message ?? "");
        return right(
          ClashTraffic.fromJson(
            jsonDecode(response.data!) as Map<String, dynamic>,
          ),
        );
      },
    );
  }
}
