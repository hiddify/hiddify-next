import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/services/singbox/ffi_singbox_service.dart';
import 'package:hiddify/services/singbox/mobile_singbox_service.dart';

abstract interface class SingboxService {
  factory SingboxService() {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileSingboxService();
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return FFISingboxService();
    }
    throw Exception("unsupported platform");
  }

  Future<void> init();

  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
    bool debug,
  );

  TaskEither<String, Unit> parseConfig(
    String path,
    String tempPath,
    bool debug,
  );

  TaskEither<String, Unit> changeConfigOptions(ConfigOptions options);

  TaskEither<String, String> generateConfig(
    String path,
  );

  TaskEither<String, Unit> start(String configPath, bool disableMemoryLimit);

  TaskEither<String, Unit> stop();

  TaskEither<String, Unit> restart(String configPath, bool disableMemoryLimit);

  Stream<String> watchOutbounds();

  TaskEither<String, Unit> selectOutbound(String groupTag, String outboundTag);

  TaskEither<String, Unit> urlTest(String groupTag);

  Stream<ConnectionStatus> watchConnectionStatus();

  Stream<String> watchStats();

  Stream<List<String>> watchLogs(String path);

  TaskEither<String, Unit> clearLogs();
}
