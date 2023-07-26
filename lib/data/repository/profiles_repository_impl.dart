import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
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
    required this.clashFacade,
    required this.dio,
  });

  final ProfilesDao profilesDao;
  final FilesEditorService filesEditor;
  final ClashFacade clashFacade;
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
    return profilesDao
        .watchActiveProfile()
        .handleExceptions(ProfileUnexpectedFailure.new);
  }

  @override
  Stream<Either<ProfileFailure, bool>> watchHasAnyProfile() {
    return profilesDao
        .watchProfileCount()
        .map((event) => event != 0)
        .handleExceptions(ProfileUnexpectedFailure.new);
  }

  @override
  Stream<Either<ProfileFailure, List<Profile>>> watchAll() {
    return profilesDao
        .watchAll()
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
      ProfileUnexpectedFailure.new,
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
      ProfileUnexpectedFailure.new,
    );
  }

  @override
  TaskEither<ProfileFailure, Unit> update(Profile baseProfile) {
    return exceptionHandler(
      () async {
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
      ProfileUnexpectedFailure.new,
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
        final response = await dio.download(url, path);
        if (response.statusCode != 200) {
          await File(path).delete();
          return left(const ProfileUnexpectedFailure());
        }
        final isValid = await clashFacade
            .validateConfig(fileName)
            .getOrElse((_) => false)
            .run();
        if (!isValid) {
          await File(path).delete();
          return left(const ProfileFailure.invalidConfig());
        }
        final profile = Profile.fromResponse(url, response.headers.map);
        return right(profile);
      },
    );
  }
}
