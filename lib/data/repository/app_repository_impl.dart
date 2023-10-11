import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/environment.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements AppRepository {
  AppRepositoryImpl(this.dio);

  final Dio dio;

  static Future<AppInfo> getAppInfo(Environment environment) async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppInfo(
      name: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      release: Release.read(),
      operatingSystem: Platform.operatingSystem,
      operatingSystemVersion: Platform.operatingSystemVersion,
      environment: environment,
    );
  }

  // TODO add market-specific update checking
  @override
  TaskEither<AppFailure, RemoteVersionInfo> getLatestVersion({
    bool includePreReleases = false,
    Release release = Release.general,
  }) {
    return exceptionHandler(
      () async {
        if (!release.allowCustomUpdateChecker) {
          throw Exception("custom update checkers are not supported");
        }
        final response = await dio.get<List>(Constants.githubReleasesApiUrl);
        if (response.statusCode != 200 || response.data == null) {
          loggy.warning("failed to fetch latest version info");
          return left(const AppFailure.unexpected());
        }

        final releases = response.data!
            .map((e) => RemoteVersionInfo.fromJson(e as Map<String, dynamic>));
        late RemoteVersionInfo latest;
        if (includePreReleases) {
          latest = releases.first;
        } else {
          latest = releases.firstWhere((e) => e.preRelease == false);
        }
        return right(latest);
      },
      AppFailure.unexpected,
    );
  }
}
