import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
class ActiveProfile extends _$ActiveProfile with AppLogger {
  @override
  Stream<Profile?> build() {
    return ref
        .watch(profilesRepositoryProvider)
        .watchActiveProfile()
        .map((event) => event.getOrElse((l) => throw l));
  }

  Future<Unit?> updateProfile() async {
    if (state case AsyncData(value: final profile?)) {
      loggy.debug("updating active profile");
      return ref
          .read(profilesRepositoryProvider)
          .update(profile)
          .getOrElse((l) => throw l)
          .run();
    }
    return null;
  }
}
