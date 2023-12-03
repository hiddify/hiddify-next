import 'dart:io';

import 'package:hiddify/services/platform_services.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

typedef Directories = ({
  Directory baseDir,
  Directory workingDir,
  Directory tempDir
});

class FilesEditorService with InfraLogger {
  FilesEditorService(this.platformServices);

  final PlatformServices platformServices;

  late final Directories dirs;

  Directory get workingDir => dirs.workingDir;

  Future<void> init() async {
    dirs = await platformServices.getPaths().getOrElse(
      (error) {
        loggy.error("error getting paths", error, StackTrace.current);
        throw error;
      },
    ).run();

    loggy.info("directories: $dirs");

    if (!await dirs.baseDir.exists()) {
      await dirs.baseDir.create(recursive: true);
    }
    if (!await dirs.workingDir.exists()) {
      await dirs.workingDir.create(recursive: true);
    }
  }

  static Future<Directory> getDatabaseDirectory() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return getLibraryDirectory();
    } else if (Platform.isWindows || Platform.isLinux) {
      return getApplicationSupportDirectory();
    }
    return getApplicationDocumentsDirectory();
  }
}
