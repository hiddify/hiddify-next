import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/app/update_failure.dart';
import 'package:hiddify/domain/app/version_info.dart';

abstract interface class UpdateRepository {
  TaskEither<UpdateFailure, InstalledVersionInfo> getCurrentVersion();

  TaskEither<UpdateFailure, RemoteVersionInfo> getLatestVersion({
    bool includePreReleases = false,
  });
}
