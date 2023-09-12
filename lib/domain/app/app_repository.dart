import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/app/app_failure.dart';
import 'package:hiddify/domain/app/app_info.dart';

abstract interface class AppRepository {
  TaskEither<AppFailure, RemoteVersionInfo> getLatestVersion({
    bool includePreReleases = false,
  });
}
