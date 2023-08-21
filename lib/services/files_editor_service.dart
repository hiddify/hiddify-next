import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FilesEditorService with InfraLogger {
  late final Directory baseDir;
  late final Directory workingDir;
  late final Directory tempDir;
  late final Directory _configsDir;

  Future<void> init() async {
    baseDir = await getApplicationSupportDirectory();
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      workingDir = externalDir!;
    } else if (Platform.isWindows) {
      workingDir = baseDir;
    } else {
      workingDir = await getApplicationDocumentsDirectory();
    }
    tempDir = await getTemporaryDirectory();

    loggy.debug("base dir: ${baseDir.path}");
    loggy.debug("working dir: ${workingDir.path}");
    loggy.debug("temp dir: ${tempDir.path}");

    _configsDir =
        Directory(p.join(workingDir.path, Constants.configsFolderName));
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    if (!await workingDir.exists()) {
      await workingDir.create(recursive: true);
    }
    if (!await _configsDir.exists()) {
      await _configsDir.create(recursive: true);
    }

    final appLogFile = File(appLogsPath);
    if (await appLogFile.exists()) {
      await appLogFile.writeAsString("");
    } else {
      await appLogFile.create(recursive: true);
    }

    await _populateGeoAssets();
    if (PlatformUtils.isDesktop) {
      final logFile = File(logsPath);
      if (await logFile.exists()) {
        await logFile.writeAsString("");
      } else {
        await logFile.create(recursive: true);
      }
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

  String get appLogsPath => p.join(workingDir.path, "app.log");
  String get logsPath => p.join(workingDir.path, "box.log");

  String configPath(String fileName) {
    return p.join(_configsDir.path, "$fileName.json");
  }

  Future<void> deleteConfig(String fileName) {
    return File(configPath(fileName)).delete();
  }

  Future<void> _populateGeoAssets() async {
    loggy.debug('populating geo assets');
    final geoipPath = p.join(workingDir.path, Constants.geoipFileName);
    if (!await File(geoipPath).exists()) {
      final defaultGeoip = await rootBundle.load(Assets.core.geoip);
      await File(geoipPath).writeAsBytes(defaultGeoip.buffer.asInt8List());
    }

    final geositePath = p.join(workingDir.path, Constants.geositeFileName);
    if (!await File(geositePath).exists()) {
      final defaultGeosite = await rootBundle.load(Assets.core.geosite);
      await File(geositePath).writeAsBytes(defaultGeosite.buffer.asInt8List());
    }
  }
}
