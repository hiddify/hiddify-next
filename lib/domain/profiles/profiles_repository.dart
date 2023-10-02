import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/profiles/profiles.dart';

abstract class ProfilesRepository {
  TaskEither<ProfileFailure, Profile?> get(String id);

  Stream<Either<ProfileFailure, Profile?>> watchActiveProfile();

  Stream<Either<ProfileFailure, bool>> watchHasAnyProfile();

  Stream<Either<ProfileFailure, List<Profile>>> watchAll({
    ProfilesSort sort = ProfilesSort.lastUpdate,
    SortMode mode = SortMode.ascending,
  });

  TaskEither<ProfileFailure, Unit> addByUrl(
    String url, {
    bool markAsActive = false,
  });

  TaskEither<ProfileFailure, Unit> addByContent(
    String content, {
    required String name,
    bool markAsActive = false,
  });

  TaskEither<ProfileFailure, Unit> add(RemoteProfile baseProfile);

  TaskEither<ProfileFailure, Unit> update(RemoteProfile baseProfile);

  TaskEither<ProfileFailure, Unit> edit(Profile profile);

  TaskEither<ProfileFailure, Unit> setAsActive(String id);

  TaskEither<ProfileFailure, Unit> delete(String id);
}
