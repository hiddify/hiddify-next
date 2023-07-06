import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/constants.dart';

abstract class ClashFacade {
  TaskEither<ClashFailure, ClashConfig> getConfigs();

  TaskEither<ClashFailure, bool> validateConfig(String configFileName);

  /// change active configuration file by [configFileName]
  TaskEither<ClashFailure, Unit> changeConfigs(String configFileName);

  TaskEither<ClashFailure, Unit> patchOverrides(ClashConfig overrides);

  TaskEither<ClashFailure, List<ClashProxy>> getProxies();

  TaskEither<ClashFailure, Unit> changeProxy(
    String selectorName,
    String proxyName,
  );

  TaskEither<ClashFailure, int> testDelay(
    String proxyName, {
    String testUrl = Constants.delayTestUrl,
  });

  TaskEither<ClashFailure, ClashTraffic> getTraffic();

  Stream<Either<ClashFailure, ClashLog>> watchLogs();
}
