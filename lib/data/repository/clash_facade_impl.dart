import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/services/clash/clash.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/utils.dart';

class ClashFacadeImpl
    with ExceptionHandler, InfraLogger
    implements ClashFacade {
  ClashFacadeImpl({
    required ClashService clashService,
    required FilesEditorService filesEditor,
  })  : _clash = clashService,
        _filesEditor = filesEditor;

  final ClashService _clash;
  final FilesEditorService _filesEditor;

  @override
  TaskEither<ClashFailure, ClashConfig> getConfigs() {
    return exceptionHandler(
      () async => _clash.getConfigs().mapLeft(ClashFailure.core).run(),
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, bool> validateConfig(String configFileName) {
    return exceptionHandler(
      () async {
        final path = _filesEditor.configPath(configFileName);
        return _clash.validateConfig(path).mapLeft(ClashFailure.core).run();
      },
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, Unit> changeConfigs(String configFileName) {
    return exceptionHandler(
      () async {
        loggy.debug("changing config, file name: [$configFileName]");
        final path = _filesEditor.configPath(configFileName);
        return _clash.updateConfigs(path).mapLeft(ClashFailure.core).run();
      },
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, Unit> patchOverrides(ClashConfig overrides) {
    return exceptionHandler(
      () async =>
          _clash.patchConfigs(overrides).mapLeft(ClashFailure.core).run(),
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, List<ClashProxy>> getProxies() {
    return exceptionHandler(
      () async => _clash.getProxies().mapLeft(ClashFailure.core).run(),
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, Unit> changeProxy(
    String selectorName,
    String proxyName,
  ) {
    return exceptionHandler(
      () async => _clash
          .changeProxy(selectorName, proxyName)
          .mapLeft(ClashFailure.core)
          .run(),
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, ClashTraffic> getTraffic() {
    return exceptionHandler(
      () async => _clash.getTraffic().mapLeft(ClashFailure.core).run(),
      ClashFailure.unexpected,
    );
  }

  @override
  TaskEither<ClashFailure, int> testDelay(
    String proxyName, {
    String testUrl = Constants.delayTestUrl,
  }) {
    return exceptionHandler(
      () async {
        final result = _clash
            .getProxyDelay(proxyName, testUrl)
            .mapLeft(ClashFailure.core)
            .run();
        return result;
      },
      ClashFailure.unexpected,
    );
  }

  @override
  Stream<Either<ClashFailure, ClashLog>> watchLogs() {
    return _clash
        .watchLogs(LogLevel.info)
        .handleExceptions(ClashFailure.unexpected);
  }
}
