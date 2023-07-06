import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FilesEditorService with InfraLogger {
  late final Directory _supportDir;
  late final Directory _clashDirectory;
  late final Directory _logsDirectory;

  Future<void> init() async {
    loggy.debug('initializing');
    _supportDir = await getApplicationSupportDirectory();
    _clashDirectory =
        Directory(p.join(_supportDir.path, Constants.clashFolderName));
    loggy.debug('clash directory: $_clashDirectory');
    if (!await _clashDirectory.exists()) {
      await _clashDirectory.create(recursive: true);
    }
    if (!await File(countryMMDBPath).exists()) {
      await _populateDefaultCountryMMDB();
    }
    if (!await File(defaultConfigPath).exists()) await _populateDefaultConfig();
  }

  String get clashDirPath => _clashDirectory.path;

  late final logsPath = p.join(
    _logsDirectory.path,
    "${DateTime.now().toUtc().toIso8601String().split('T').first}.txt",
  );

  String get defaultConfigPath => configPath("config");

  String configPath(String fileName) {
    return p.join(_clashDirectory.path, "$fileName.yaml");
  }

  Future<void> deleteConfig(String fileName) {
    return File(configPath(fileName)).delete();
  }

  String get countryMMDBPath {
    return p.join(
      _clashDirectory.path,
      "${Constants.countryMMDBFileName}.mmdb",
    );
  }

  Future<void> _populateDefaultConfig() async {
    loggy.debug('populating default config file');
    final defaultConfig = await rootBundle.load(Assets.core.clash.config);
    await File(defaultConfigPath)
        .writeAsBytes(defaultConfig.buffer.asInt8List());
  }

  Future<void> _populateDefaultCountryMMDB() async {
    loggy.debug('populating default country mmdb file');
    final defaultCountryMMDB = await rootBundle.load(Assets.core.clash.country);
    await File(countryMMDBPath)
        .writeAsBytes(defaultCountryMMDB.buffer.asInt8List());
  }
}
