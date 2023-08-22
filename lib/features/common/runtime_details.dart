import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'runtime_details.freezed.dart';
part 'runtime_details.g.dart';

// TODO add clash version
@Riverpod(keepAlive: true)
class RuntimeDetailsNotifier extends _$RuntimeDetailsNotifier with AppLogger {
  @override
  Future<RuntimeDetails> build() async {
    loggy.debug("initializing");
    final appVersion = await ref
        .watch(updateRepositoryProvider)
        .getCurrentVersion()
        .getOrElse((l) => throw l)
        .run();
    return RuntimeDetails(appVersion: appVersion);
  }

  Future<void> checkForUpdates() async {
    if (state case AsyncData(:final value)) {
      switch (value.latestVersion) {
        case AsyncLoading():
          return;
        default:
          loggy.debug("checking for updates");
          state =
              AsyncData(value.copyWith(latestVersion: const AsyncLoading()));
          // TODO use prefs
          const includePreReleases = true;
          await ref
              .read(updateRepositoryProvider)
              .getLatestVersion(includePreReleases: includePreReleases)
              .match(
            (l) {
              loggy.warning("failed to get latest version, $l");
              state = AsyncData(
                value.copyWith(
                  latestVersion: AsyncError(l, StackTrace.current),
                ),
              );
            },
            (r) {
              state = AsyncData(
                value.copyWith(latestVersion: AsyncData(r)),
              );
            },
          ).run();
      }
    }
  }
}

@Riverpod(keepAlive: true)
AsyncValue<InstalledVersionInfo> appVersion(AppVersionRef ref) => ref.watch(
      runtimeDetailsNotifierProvider
          .select((value) => value.whenData((value) => value.appVersion)),
    );

@freezed
class RuntimeDetails with _$RuntimeDetails {
  const RuntimeDetails._();

  const factory RuntimeDetails({
    required InstalledVersionInfo appVersion,
    @Default(AsyncData(null)) AsyncValue<RemoteVersionInfo?> latestVersion,
  }) = _RuntimeDetails;

  bool get newVersionAvailable => latestVersion.maybeWhen(
        data: (data) =>
            data != null &&
            data.fullVersion.compareTo(this.appVersion.fullVersion) > 0,
        orElse: () => false,
      );
}
