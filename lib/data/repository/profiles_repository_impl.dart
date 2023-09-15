import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class ProfilesRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements ProfilesRepository {
  ProfilesRepositoryImpl({
    required this.profilesDao,
    required this.filesEditor,
    required this.singbox,
    required this.dio,
  });

  final ProfilesDao profilesDao;
  final FilesEditorService filesEditor;
  final SingboxFacade singbox;
  final Dio dio;

  @override
  TaskEither<ProfileFailure, Profile?> get(String id) {
    return TaskEither.tryCatch(
      () => profilesDao.getById(id),
      ProfileUnexpectedFailure.new,
    );
  }

  @override
  Stream<Either<ProfileFailure, Profile?>> watchActiveProfile() {
    return profilesDao.watchActiveProfile().handleExceptions(
      (error, stackTrace) {
        loggy.warning("error watching active profile", error, stackTrace);
        return ProfileUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  Stream<Either<ProfileFailure, bool>> watchHasAnyProfile() {
    return profilesDao
        .watchProfileCount()
        .map((event) => event != 0)
        .handleExceptions(ProfileUnexpectedFailure.new);
  }

  @override
  Stream<Either<ProfileFailure, List<Profile>>> watchAll({
    ProfilesSort sort = ProfilesSort.lastUpdate,
    SortMode mode = SortMode.ascending,
  }) {
    return profilesDao
        .watchAll(sort: sort, mode: mode)
        .handleExceptions(ProfileUnexpectedFailure.new);
  }

  @override
  TaskEither<ProfileFailure, Unit> addByUrl(
    String url, {
    bool markAsActive = false,
  }) {
    return exceptionHandler(
      () async {
        final profileId = const Uuid().v4();
        return fetch(url, profileId)
            .flatMap(
              (profile) => TaskEither(
                () async {
                  await profilesDao.create(
                    profile.copyWith(
                      id: profileId,
                      active: markAsActive,
                    ),
                  );
                  return right(unit);
                },
              ),
            )
            .run();
      },
      (error, stackTrace) {
        loggy.warning("error adding profile by url", error, stackTrace);
        return ProfileUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> add(Profile baseProfile) {
    return exceptionHandler(
      () async {
        return fetch(baseProfile.url, baseProfile.id)
            .flatMap(
              (remoteProfile) => TaskEither(() async {
                await profilesDao.create(
                  baseProfile.copyWith(
                    subInfo: remoteProfile.subInfo,
                    extra: remoteProfile.extra,
                    lastUpdate: DateTime.now(),
                  ),
                );
                return right(unit);
              }),
            )
            .run();
      },
      (error, stackTrace) {
        loggy.warning("error adding profile", error, stackTrace);
        return ProfileUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> update(Profile baseProfile) {
    return exceptionHandler(
      () async {
        loggy.debug(
          "updating profile [${baseProfile.name} (${baseProfile.id})]",
        );
        return fetch(baseProfile.url, baseProfile.id)
            .flatMap(
              (remoteProfile) => TaskEither(() async {
                await profilesDao.edit(
                  baseProfile.copyWith(
                    subInfo: remoteProfile.subInfo,
                    extra: remoteProfile.extra,
                    lastUpdate: DateTime.now(),
                  ),
                );
                return right(unit);
              }),
            )
            .run();
      },
      (error, stackTrace) {
        loggy.warning("error updating profile", error, stackTrace);
        return ProfileUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> setAsActive(String id) {
    return TaskEither.tryCatch(
      () async {
        await profilesDao.setAsActive(id);
        return unit;
      },
      ProfileUnexpectedFailure.new,
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> delete(String id) {
    return TaskEither.tryCatch(
      () async {
        await profilesDao.removeById(id);
        await filesEditor.deleteConfig(id);
        return unit;
      },
      ProfileUnexpectedFailure.new,
    );
  }

  @visibleForTesting
  TaskEither<ProfileFailure, Profile> fetch(
    String url,
    String fileName,
  ) {
    return TaskEither(
      () async {
        final path = filesEditor.configPath(fileName);
        final response = await dio.download(url.trim(), path);
        final parseResult = await singbox.parseConfig(path).run();
        return parseResult.fold(
          (l) async {
            await File(path).delete();
            loggy.warning("error parsing config: $l");
            return left(ProfileFailure.invalidConfig(l.msg));
          },
          (_) async {
            final responseString = await File(path).readAsString();
            final headers = addHeadersFromBody(response.headers.map, responseString);
            final profile = Profile.fromResponse(url, headers);
            return right(profile);
          },
        );
      },
    );
  }

  Map<String, List<String>> addHeadersFromBody(
    Map<String, List<String>> headers,
    String responseString,
  ) {
    final allowedHeaders = [
      'profile-title',
      'content-disposition',
      'subscription-userinfo',
      'profile-update-interval',
      'support-url',
      'profile-web-page-url'
    ];
    for (final text in responseString.split("\n")) {
      if (text.startsWith("#") || text.startsWith("//")) {
        final index = text.indexOf(':');
        if (index == -1) continue;
        final headerTitle = text
            .substring(0, index)
            .replaceFirst(RegExp("^#|//"), "")
            .trim()
            .toLowerCase();
        final headerValue = text.substring(index + 1).trim();
        if (!headers.keys.contains(headerTitle) &&
            allowedHeaders.contains(headerTitle) &&
            headerValue.isNotEmpty) {
          headers[headerTitle] = [headerValue];
        }
      }
    }
    return headers;
  }
}
