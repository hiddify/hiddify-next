import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
class ActiveProfile extends _$ActiveProfile with AppLogger {
  @override
  Stream<Profile?> build() {
    loggy.debug("watching active profile");
    return ref
        .watch(profilesRepositoryProvider)
        .watchActiveProfile()
        .map((event) => event.getOrElse((l) => throw l));
  }
}
