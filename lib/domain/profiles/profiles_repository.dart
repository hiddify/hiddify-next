import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/profiles/profiles.dart';

abstract class ProfilesRepository {
  TaskEither<ProfileFailure, Profile?> get(String id);

  Stream<Either<ProfileFailure, Profile?>> watchActiveProfile();

  Stream<Either<ProfileFailure, bool>> watchHasAnyProfile();

  Stream<Either<ProfileFailure, List<Profile>>> watchAll();

  TaskEither<ProfileFailure, Unit> addByUrl(
    String url, {
    bool markAsActive = false,
  });

  TaskEither<ProfileFailure, Unit> add(Profile baseProfile);

  TaskEither<ProfileFailure, Unit> update(Profile baseProfile);

  TaskEither<ProfileFailure, Unit> setAsActive(String id);

  TaskEither<ProfileFailure, Unit> delete(String id);
}
