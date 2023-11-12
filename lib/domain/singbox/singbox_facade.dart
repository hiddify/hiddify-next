import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/singbox/config_options.dart';
import 'package:hiddify/domain/singbox/core_status.dart';
import 'package:hiddify/domain/singbox/outbounds.dart';

abstract interface class SingboxFacade {
  TaskEither<CoreServiceFailure, Unit> setup();

  TaskEither<CoreServiceFailure, Unit> parseConfig(
    String path,
    String tempPath,
    bool debug,
  );

  TaskEither<CoreServiceFailure, Unit> changeConfigOptions(
    ConfigOptions options,
  );

  TaskEither<CoreServiceFailure, String> generateConfig(
    String fileName,
  );

  TaskEither<CoreServiceFailure, Unit> start(
    String fileName,
    bool disableMemoryLimit,
  );

  TaskEither<CoreServiceFailure, Unit> stop();

  TaskEither<CoreServiceFailure, Unit> restart(
    String fileName,
    bool disableMemoryLimit,
  );

  Stream<Either<CoreServiceFailure, List<OutboundGroup>>> watchOutbounds();

  TaskEither<CoreServiceFailure, Unit> selectOutbound(
    String groupTag,
    String outboundTag,
  );

  TaskEither<CoreServiceFailure, Unit> urlTest(String groupTag);

  Stream<ConnectionStatus> watchConnectionStatus();

  Stream<Either<CoreServiceFailure, CoreStatus>> watchCoreStatus();

  Stream<Either<CoreServiceFailure, List<String>>> watchLogs();

  TaskEither<CoreServiceFailure, Unit> clearLogs();
}
