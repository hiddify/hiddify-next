import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

part 'platform_services.freezed.dart';
part 'platform_services.g.dart';

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

  TaskEither<String, bool> isIgnoringBatteryOptimizations() {
    return TaskEither(
      () async {
        loggy.debug("checking battery optimization status");
        final result = await _methodChannel
            .invokeMethod<bool>("is_ignoring_battery_optimizations");
        loggy.debug("is ignoring battery optimizations? [$result]");
        return right(result!);
      },
    );
  }

  TaskEither<String, bool> requestIgnoreBatteryOptimizations() {
    return TaskEither(
      () async {
        loggy.debug("requesting ignore battery optimization");
        final result = await _methodChannel
            .invokeMethod<bool>("request_ignore_battery_optimizations");
        loggy.debug("ignore battery optimization result: [$result]");
        return right(result!);
      },
    );
  }

  TaskEither<String, List<InstalledPackageInfo>> getInstalledPackages() {
    return TaskEither(
      () async {
        loggy.debug("getting installed packages info");
        final result =
            await _methodChannel.invokeMethod<String>("get_installed_packages");
        if (result == null) return left("null response");
        return right(
          (jsonDecode(result) as List).map((e) {
            return InstalledPackageInfo.fromJson(e as Map<String, dynamic>);
          }).toList(),
        );
      },
    );
  }

  TaskEither<String, Uint8List> getPackageIcon(
    String packageName,
  ) {
    return TaskEither(
      () async {
        loggy.debug("getting package [$packageName] icon");
        final result = await _methodChannel.invokeMethod<String>(
          "get_package_icon",
          {"packageName": packageName},
        );
        if (result == null) return left("null response");
        final Uint8List decoded;
        try {
          decoded = base64.decode(result);
        } catch (e) {
          return left("error parsing base64 response");
        }
        return right(decoded);
      },
    );
  }
}

@freezed
class InstalledPackageInfo with _$InstalledPackageInfo {
  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory InstalledPackageInfo({
    required String packageName,
    required String name,
    required bool isSystemApp,
  }) = _InstalledPackageInfo;

  factory InstalledPackageInfo.fromJson(Map<String, dynamic> json) =>
      _$InstalledPackageInfoFromJson(json);
}
