import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/core_service_failure.dart';

abstract class ClashFacade {
  TaskEither<CoreServiceFailure, ClashConfig> getConfigs();

  TaskEither<CoreServiceFailure, Unit> patchOverrides(ClashConfig overrides);

  TaskEither<CoreServiceFailure, List<ClashProxy>> getProxies();

  TaskEither<CoreServiceFailure, Unit> changeProxy(
    String selectorName,
    String proxyName,
  );

  TaskEither<CoreServiceFailure, int> testDelay(
    String proxyName, {
    String testUrl = Defaults.connectionTestUrl,
  });

  Stream<Either<CoreServiceFailure, ClashTraffic>> watchTraffic();
}
