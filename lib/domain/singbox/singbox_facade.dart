import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/singbox/config_options.dart';
import 'package:hiddify/domain/singbox/core_status.dart';
import 'package:hiddify/domain/singbox/outbounds.dart';

abstract interface class SingboxFacade {
  TaskEither<CoreServiceFailure, Unit> setup();

  TaskEither<CoreServiceFailure, Unit> parseConfig(String path);

  TaskEither<CoreServiceFailure, Unit> changeConfigOptions(
    ConfigOptions options,
  );

  TaskEither<CoreServiceFailure, Unit> changeConfig(String fileName);

  TaskEither<CoreServiceFailure, Unit> start();

  TaskEither<CoreServiceFailure, Unit> stop();

  Stream<Either<CoreServiceFailure, List<OutboundGroup>>> watchOutbounds();

  TaskEither<CoreServiceFailure, Unit> selectOutbound(
    String groupTag,
    String outboundTag,
  );

  TaskEither<CoreServiceFailure, Unit> urlTest(String groupTag);

  Stream<Either<CoreServiceFailure, CoreStatus>> watchCoreStatus();

  Stream<Either<CoreServiceFailure, String>> watchLogs();
}
