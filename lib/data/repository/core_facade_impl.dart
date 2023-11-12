import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/api/clash_api.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connection_status.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/core_facade.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/services/platform_services.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';

class CoreFacadeImpl with ExceptionHandler, InfraLogger implements CoreFacade {
  CoreFacadeImpl(
    this.singbox,
    this.filesEditor,
    this.platformServices,
    this.clash,
    this.debug,
    this.configOptions,
  );

  final SingboxService singbox;
  final FilesEditorService filesEditor;
  final PlatformServices platformServices;
  final ClashApi clash;
  final bool debug;
  final ConfigOptions Function() configOptions;

  bool _initialized = false;

  @override
  TaskEither<CoreServiceFailure, Unit> setup() {
    if (_initialized) return TaskEither.of(unit);
    return exceptionHandler(
      () {
        loggy.debug("setting up singbox");
        return singbox
            .setup(
              filesEditor.dirs.baseDir.path,
              filesEditor.dirs.workingDir.path,
              filesEditor.dirs.tempDir.path,
              debug,
            )
            .map((r) {
              loggy.debug("setup complete");
              _initialized = true;
              return r;
            })
            .mapLeft(CoreServiceFailure.other)
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> parseConfig(
    String path,
    String tempPath,
    bool debug,
  ) {
    return exceptionHandler(
      () {
        return singbox
            .parseConfig(path, tempPath, debug)
            .mapLeft(CoreServiceFailure.invalidConfig)
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> changeConfigOptions(
    ConfigOptions options,
  ) {
    return exceptionHandler(
      () {
        return singbox
            .changeConfigOptions(options)
            .mapLeft(CoreServiceFailure.invalidConfigOptions)
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, String> generateConfig(
    String fileName,
  ) {
    return exceptionHandler(
      () {
        final configPath = filesEditor.configPath(fileName);
        final options = configOptions();
        return setup()
            .andThen(() => changeConfigOptions(options))
            .andThen(
              () => singbox
                  .generateConfig(configPath)
                  .mapLeft(CoreServiceFailure.other),
            )
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> start(
    String fileName,
    bool disableMemoryLimit,
  ) {
    return exceptionHandler(
      () async {
        final configPath = filesEditor.configPath(fileName);
        final options = configOptions();
        loggy.info(
          "config options: ${options.format()}\nMemory Limit: ${!disableMemoryLimit}",
        );

        if (options.enableTun) {
          final hasPrivilege = await platformServices.hasPrivilege();
          if (!hasPrivilege) {
            loggy.warning("missing privileges for tun mode");
            return left(const CoreMissingPrivilege());
          }
        }

        return setup()
            .andThen(() => changeConfigOptions(options))
            .andThen(
              () => singbox
                  .start(configPath, disableMemoryLimit)
                  .mapLeft(CoreServiceFailure.start),
            )
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> stop() {
    return exceptionHandler(
      () => singbox.stop().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> restart(
    String fileName,
    bool disableMemoryLimit,
  ) {
    return exceptionHandler(
      () {
        final configPath = filesEditor.configPath(fileName);
        return changeConfigOptions(configOptions())
            .andThen(
              () => singbox
                  .restart(configPath, disableMemoryLimit)
                  .mapLeft(CoreServiceFailure.start),
            )
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<Either<CoreServiceFailure, List<OutboundGroup>>> watchOutbounds() {
    return singbox.watchOutbounds().map((event) {
      return (jsonDecode(event) as List).map((e) {
        return OutboundGroup.fromJson(e as Map<String, dynamic>);
      }).toList();
    }).handleExceptions(
      (error, stackTrace) {
        loggy.error("error watching outbounds", error, stackTrace);
        return CoreServiceFailure.unexpected(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> selectOutbound(
    String groupTag,
    String outboundTag,
  ) {
    return exceptionHandler(
      () => singbox
          .selectOutbound(groupTag, outboundTag)
          .mapLeft(CoreServiceFailure.other)
          .run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> urlTest(String groupTag) {
    return exceptionHandler(
      () => singbox.urlTest(groupTag).mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<Either<CoreServiceFailure, CoreStatus>> watchCoreStatus() {
    return singbox.watchStats().map((event) {
      final json = jsonDecode(event);
      return CoreStatus.fromJson(json as Map<String, dynamic>);
    }).handleExceptions(
      (error, stackTrace) {
        loggy.warning("error watching status", error, stackTrace);
        return CoreServiceFailure.unexpected(error, stackTrace);
      },
    );
  }

  @override
  Stream<Either<CoreServiceFailure, List<String>>> watchLogs() {
    return singbox.watchLogs(filesEditor.coreLogsFile.path).handleExceptions(
      (error, stackTrace) {
        loggy.warning("error watching logs", error, stackTrace);
        return CoreServiceFailure.unexpected(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> clearLogs() {
    return exceptionHandler(
      () => singbox.clearLogs().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, ClashConfig> getConfigs() {
    return exceptionHandler(
      () async => clash.getConfigs().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> patchOverrides(ClashConfig overrides) {
    return exceptionHandler(
      () async =>
          clash.patchConfigs(overrides).mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, List<ClashProxy>> getProxies() {
    return exceptionHandler(
      () async => clash.getProxies().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> changeProxy(
    String selectorName,
    String proxyName,
  ) {
    return exceptionHandler(
      () async => clash
          .changeProxy(selectorName, proxyName)
          .mapLeft(CoreServiceFailure.other)
          .run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<Either<CoreServiceFailure, ClashTraffic>> watchTraffic() {
    return clash.watchTraffic().handleExceptions(CoreServiceFailure.unexpected);
  }

  @override
  TaskEither<CoreServiceFailure, int> testDelay(
    String proxyName, {
    String testUrl = Defaults.connectionTestUrl,
  }) {
    return exceptionHandler(
      () async {
        final result = clash
            .getProxyDelay(proxyName, testUrl)
            .mapLeft(CoreServiceFailure.other)
            .run();
        return result;
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() =>
      singbox.watchConnectionStatus();
}
