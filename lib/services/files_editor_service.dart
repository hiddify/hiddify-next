import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/services/platform_services.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;
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
  Directory get configsDir =>
      Directory(p.join(workingDir.path, Constants.configsFolderName));
  Directory get logsDir => dirs.workingDir;

  Directory get geoAssetsDir =>
      Directory(p.join(workingDir.path, "geo-assets"));

  File get appLogsFile => File(p.join(logsDir.path, "app.log"));
  File get coreLogsFile => File(p.join(logsDir.path, "box.log"));

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
    if (!await configsDir.exists()) {
      await configsDir.create(recursive: true);
    }
    if (!await geoAssetsDir.exists()) {
      await geoAssetsDir.create(recursive: true);
    }

    if (await appLogsFile.exists()) {
      await appLogsFile.writeAsString("");
    } else {
      await appLogsFile.create(recursive: true);
    }

    if (await coreLogsFile.exists()) {
      await coreLogsFile.writeAsString("");
    } else {
      await coreLogsFile.create(recursive: true);
    }

    await _populateGeoAssets();
  }

  static Future<Directory> getDatabaseDirectory() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return getLibraryDirectory();
    } else if (Platform.isWindows || Platform.isLinux) {
      return getApplicationSupportDirectory();
    }
    return getApplicationDocumentsDirectory();
  }

  String configPath(String fileName) {
    return p.join(configsDir.path, "$fileName.json");
  }

  String geoAssetPath(String providerName, String fileName) {
    final prefix = providerName.replaceAll("/", "-").toLowerCase();
    return p.join(
      geoAssetsDir.path,
      "$prefix${prefix.isBlank ? "" : "-"}$fileName",
    );
  }

  /// geoasset's path relative to working directory
  String geoAssetRelativePath(String providerName, String fileName) {
    final fullPath = geoAssetPath(providerName, fileName);
    return p.relative(fullPath, from: workingDir.path);
  }

  String tempConfigPath(String fileName) => configPath("temp_$fileName");

  Future<void> deleteConfig(String fileName) {
    return File(configPath(fileName)).delete();
  }

  Future<void> _populateGeoAssets() async {
    loggy.debug('populating geo assets');
    final geoipPath =
        geoAssetPath(defaultGeoip.providerName, defaultGeoip.fileName);
    if (!await File(geoipPath).exists()) {
      final bundledGeoip = await rootBundle.load(Assets.core.geoip);
      await File(geoipPath).writeAsBytes(bundledGeoip.buffer.asInt8List());
    }

    final geositePath =
        geoAssetPath(defaultGeosite.providerName, defaultGeosite.fileName);
    if (!await File(geositePath).exists()) {
      final bundledGeosite = await rootBundle.load(Assets.core.geosite);
      await File(geositePath).writeAsBytes(bundledGeosite.buffer.asInt8List());
    }
  }
}
