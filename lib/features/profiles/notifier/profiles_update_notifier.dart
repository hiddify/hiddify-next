import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profiles_update_notifier.g.dart';

typedef ProfileUpdateResult = ({
  String name,
  Either<ProfileFailure, Unit> failureOrSuccess
});

@Riverpod(keepAlive: true)
class ProfilesUpdateNotifier extends _$ProfilesUpdateNotifier with AppLogger {
  @override
  Stream<ProfileUpdateResult> build() {
    _schedule();
    return const Stream.empty();
  }

  Future<void> _schedule() async {
    loggy.debug("scheduling profiles update worker");
    return ref.read(cronServiceProvider).schedule(
          key: 'profiles_update',
          duration: const Duration(minutes: 10),
          callback: () async {
            final failureOrProfiles =
                await ref.read(profilesRepositoryProvider).watchAll().first;
            if (failureOrProfiles case Right(value: final profiles)) {
              for (final profile in profiles) {
                if (profile case RemoteProfile()) {
                  loggy.debug("checking profile: [${profile.name}]");
                  final updateInterval = profile.options?.updateInterval;
                  if (updateInterval != null &&
                      updateInterval <=
                          DateTime.now().difference(profile.lastUpdate)) {
                    final failureOrSuccess = await ref
                        .read(profilesRepositoryProvider)
                        .update(profile)
                        .run();
                    state = AsyncData(
                      (name: profile.name, failureOrSuccess: failureOrSuccess),
                    );
                  } else {
                    loggy.debug("skipping profile: [${profile.name}]");
                  }
                }
              }
            }
          },
        );
  }
}
