import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';

part 'app_update_notifier.freezed.dart';
part 'app_update_notifier.g.dart';

const _debugUpgrader = true;

@riverpod
Upgrader upgrader(UpgraderRef ref) => Upgrader(
      appcastConfig: AppcastConfiguration(url: Constants.appCastUrl),
      debugLogging: _debugUpgrader && kDebugMode,
      durationUntilAlertAgain: const Duration(hours: 12),
      messages: UpgraderMessages(
        code: ref.watch(localeNotifierProvider).languageCode,
      ),
    );

@freezed
class AppUpdateState with _$AppUpdateState {
  const factory AppUpdateState.initial() = AppUpdateStateInitial;
  const factory AppUpdateState.disabled() = AppUpdateStateDisabled;
  const factory AppUpdateState.checking() = AppUpdateStateChecking;
  const factory AppUpdateState.error(AppFailure error) = AppUpdateStateError;
  const factory AppUpdateState.available(RemoteVersionInfo versionInfo) =
      AppUpdateStateAvailable;
  const factory AppUpdateState.ignored(RemoteVersionInfo versionInfo) =
      AppUpdateStateIgnored;
  const factory AppUpdateState.notAvailable() = AppUpdateStateNotAvailable;
}

@Riverpod(keepAlive: true)
class AppUpdateNotifier extends _$AppUpdateNotifier with AppLogger {
  @override
  AppUpdateState build() {
    // _schedule();
    return const AppUpdateState.initial();
  }

  Pref<String?, dynamic> get _ignoreReleasePref => Pref(
        ref.read(sharedPreferencesProvider),
        'ignored_release_version',
        null,
      );

  Future<AppUpdateState> check() async {
    loggy.debug("checking for update");
    state = const AppUpdateState.checking();
    final appInfo = ref.watch(appInfoProvider);
    // TODO use market-specific update checkers
    if (!appInfo.release.allowCustomUpdateChecker) {
      loggy.debug(
        "custom update checkers are not allowed for [${appInfo.release.name}] release",
      );
      return state = const AppUpdateState.disabled();
    }
    return ref.watch(appRepositoryProvider).getLatestVersion().match(
      (err) {
        loggy.warning("failed to get latest version", err);
        return state = AppUpdateState.error(err);
      },
      (remote) {
        try {
          final latestVersion = Version.parse(remote.version);
          final currentVersion = Version.parse(appInfo.version);
          if (latestVersion > currentVersion) {
            if (remote.version == _ignoreReleasePref.getValue()) {
              loggy.debug("ignored release [${remote.version}]");
              return state = AppUpdateStateIgnored(remote);
            }
            loggy.debug("new version available: $remote");
            return state = AppUpdateState.available(remote);
          }
          loggy.info(
            "already using latest version[$currentVersion], remote: [${remote.version}]",
          );
          return state = const AppUpdateState.notAvailable();
        } catch (error, stackTrace) {
          loggy.warning("error parsing versions", error, stackTrace);
          return state = AppUpdateState.error(
            AppFailure.unexpected(error, stackTrace),
          );
        }
      },
    ).run();
  }

  Future<void> ignoreRelease(RemoteVersionInfo versionInfo) async {
    loggy.debug("ignoring release [${versionInfo.version}]");
    await _ignoreReleasePref.update(versionInfo.version);
    state = AppUpdateStateIgnored(versionInfo);
  }

  // Future<void> _schedule() async {
  //   loggy.debug("scheduling app update checker");
  //   return ref.read(cronServiceProvider).schedule(
  //         key: 'app_update',
  //         duration: const Duration(hours: 8),
  //         callback: () async {
  //           await Future.delayed(const Duration(seconds: 5));
  //           final updateState = await check();
  //           final context = rootNavigatorKey.currentContext;
  //           if (context != null && context.mounted) {
  //             if (updateState
  //                 case AppUpdateStateAvailable(:final versionInfo)) {
  //               await NewVersionDialog(
  //                 ref.read(appInfoProvider).presentVersion,
  //                 versionInfo,
  //               ).show(context);
  //             }
  //           }
  //         },
  //       );
  // }
}
