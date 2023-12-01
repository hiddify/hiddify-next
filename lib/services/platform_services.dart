import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class PlatformServices with InfraLogger {
  final _methodChannel = const MethodChannel("app.hiddify.com/platform");

  TaskEither<String, Directories> getPaths() {
    return TaskEither(
      () async {
        loggy.debug("getting paths");
        final Directories dirs;
        if (Platform.isIOS) {
          final paths = await _methodChannel.invokeMethod<Map>("get_paths");
          loggy.debug("paths: $paths");
          dirs = (
            baseDir: Directory(paths?["base"]! as String),
            workingDir: Directory(paths?["working"]! as String),
            tempDir: Directory(paths?["temp"]! as String),
          );
        } else {
          final baseDir = await getApplicationSupportDirectory();
          final workingDir = Platform.isAndroid
              ? await getExternalStorageDirectory()
              : baseDir;
          final tempDir = await getTemporaryDirectory();
          dirs = (
            baseDir: baseDir,
            workingDir: workingDir!,
            tempDir: tempDir,
          );
        }
        return right(dirs);
      },
    );
  }
}
