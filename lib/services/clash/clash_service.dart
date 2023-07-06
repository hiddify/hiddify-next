import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/clash/clash.dart';

abstract class ClashService {
  Future<void> init();

  Future<void> start({String configFileName = "config"});

  TaskEither<String, bool> validateConfig(String configPath);

  TaskEither<String, List<ClashProxy>> getProxies();

  TaskEither<String, Unit> changeProxy(
    String selectorName,
    String proxyName,
  );

  TaskEither<String, int> getProxyDelay(
    String name,
    String url, {
    Duration timeout = const Duration(seconds: 10),
  });

  TaskEither<String, ClashConfig> getConfigs();

  TaskEither<String, Unit> updateConfigs(String path);

  TaskEither<String, Unit> patchConfigs(ClashConfig config);

  Stream<ClashLog> watchLogs(LogLevel level);

  TaskEither<String, ClashTraffic> getTraffic();
}
