import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements UpdateRepository {
  UpdateRepositoryImpl(this.dio);

  final Dio dio;

  @override
  TaskEither<UpdateFailure, InstalledVersionInfo> getCurrentVersion() {
    return exceptionHandler(
      () async {
        final packageInfo = await PackageInfo.fromPlatform();
        return right(
          InstalledVersionInfo(
            version: packageInfo.version,
            buildNumber: packageInfo.buildNumber,
            installerMedia: packageInfo.installerStore,
          ),
        );
      },
      UpdateFailure.unexpected,
    );
  }

  @override
  TaskEither<UpdateFailure, RemoteVersionInfo> getLatestVersion({
    bool includePreReleases = false,
  }) {
    return exceptionHandler(
      () async {
        final response = await dio.get<List>(Constants.githubReleasesApiUrl);

        if (response.statusCode != 200 || response.data == null) {
          loggy.warning("failed to fetch latest version info");
          return left(const UpdateFailure.unexpected());
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
      UpdateFailure.unexpected,
    );
  }
}
