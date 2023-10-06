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
import 'package:retry/retry.dart';
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
        loggy.error("error watching active profile", error, stackTrace);
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
        final existingProfile = await profilesDao.getProfileByUrl(url);
        if (existingProfile case RemoteProfile()) {
          loggy.info("profile with same url already exists, updating");
          final baseProfile = markAsActive
              ? existingProfile.copyWith(active: true)
              : existingProfile;
          return update(baseProfile).run();
        }

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
  TaskEither<ProfileFailure, Unit> addByContent(
    String content, {
    required String name,
    bool markAsActive = false,
  }) {
    return exceptionHandler(
      () async {
        final profileId = const Uuid().v4();
        final tempPath = filesEditor.tempConfigPath(profileId);
        final path = filesEditor.configPath(profileId);
        try {
          await File(tempPath).writeAsString(content);
          final parseResult =
              await singbox.parseConfig(path, tempPath, false).run();
          return parseResult.fold(
            (err) async {
              loggy.warning("error parsing config", err);
              return left(ProfileFailure.invalidConfig(err.msg));
            },
            (_) async {
              final profile = LocalProfile(
                id: profileId,
                active: markAsActive,
                name: name,
                lastUpdate: DateTime.now(),
              );
              await profilesDao.create(profile);
              return right(unit);
            },
          );
        } finally {
          if (File(tempPath).existsSync()) File(tempPath).deleteSync();
        }
      },
      (error, stackTrace) {
        loggy.warning("error adding profile by content", error, stackTrace);
        return ProfileUnexpectedFailure(error, stackTrace);
      },
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> add(RemoteProfile baseProfile) {
    return exceptionHandler(
      () async {
        return fetch(baseProfile.url, baseProfile.id)
            .flatMap(
              (remoteProfile) => TaskEither(() async {
                await profilesDao.create(
                  baseProfile.copyWith(
                    subInfo: remoteProfile.subInfo,
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
  TaskEither<ProfileFailure, Unit> update(RemoteProfile baseProfile) {
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
  TaskEither<ProfileFailure, Unit> edit(Profile profile) {
    return exceptionHandler(
      () async {
        loggy.debug(
          "editing profile [${profile.name} (${profile.id})]",
        );
        await profilesDao.edit(profile);
        return right(unit);
      },
      (error, stackTrace) {
        loggy.warning("error editing profile", error, stackTrace);
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

  final _subInfoHeaders = [
    'profile-title',
    'content-disposition',
    'subscription-userinfo',
    'profile-update-interval',
    'support-url',
    'profile-web-page-url',
  ];

  @visibleForTesting
  TaskEither<ProfileFailure, RemoteProfile> fetch(
    String url,
    String fileName,
  ) {
    return TaskEither(
      () async {
        final tempPath = filesEditor.tempConfigPath(fileName);
        final path = filesEditor.configPath(fileName);
        try {
          final response = await retry(
            () async => dio.download(url.trim(), tempPath),
            maxAttempts: 3,
          );
          final headers =
              await _populateHeaders(response.headers.map, tempPath);
          final parseResult =
              await singbox.parseConfig(path, tempPath, false).run();
          return parseResult.fold(
            (err) async {
              loggy.warning("error parsing config", err);
              return left(ProfileFailure.invalidConfig(err.msg));
            },
            (_) async {
              final profile = Profile.fromResponse(url, headers);
              return right(profile);
            },
          );
        } finally {
          if (File(tempPath).existsSync()) File(tempPath).deleteSync();
        }
      },
    );
  }

  Future<Map<String, List<String>>> _populateHeaders(
    Map<String, List<String>> headers,
    String path,
  ) async {
    var headersFound = 0;
    for (final key in _subInfoHeaders) {
      if (headers.containsKey(key)) headersFound++;
    }
    if (headersFound >= 4) return headers;

    loggy.debug(
      "only [$headersFound] headers found, checking file content for possible information",
    );
    var content = await File(path).readAsString();
    content = safeDecodeBase64(content);
    final lines = content.split("\n");
    final linesToProcess = lines.length < 10 ? lines.length : 10;
    for (int i = 0; i < linesToProcess; i++) {
      final line = lines[i];
      if (line.startsWith("#") || line.startsWith("//")) {
        final index = line.indexOf(':');
        if (index == -1) continue;
        final key = line
            .substring(0, index)
            .replaceFirst(RegExp("^#|//"), "")
            .trim()
            .toLowerCase();
        final value = line.substring(index + 1).trim();
        if (!headers.keys.contains(key) &&
            _subInfoHeaders.contains(key) &&
            value.isNotEmpty) {
          headers[key] = [value];
        }
      }
    }
    return headers;
  }
}
