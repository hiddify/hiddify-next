import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/config_option/data/config_option_data_providers.dart';
import 'package:hiddify/features/config_option/model/config_option_failure.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'warp_option_notifier.freezed.dart';
part 'warp_option_notifier.g.dart';

@Riverpod(keepAlive: true)
class WarpOptionNotifier extends _$WarpOptionNotifier with AppLogger {
  @override
  WarpOptions build() {
    final consent = _prefs.getBool(warpConsentGiven) ?? false;
    bool hasWarpConfig = false;
    try {
      final accountId = _prefs.getString("warp-account-id");
      final accessToken = _prefs.getString("warp-access-token");
      hasWarpConfig = accountId != null && accessToken != null;
    } catch (e) {
      loggy.warning(e);
    }

    return WarpOptions(
      consentGiven: consent,
      configGeneration: hasWarpConfig
          ? const AsyncValue.data("")
          : AsyncError(const MissingWarpConfigFailure(), StackTrace.current),
    );
  }

  SharedPreferences get _prefs =>
      ref.read(sharedPreferencesProvider).requireValue;

  Future<void> agree() async {
    await ref
        .read(sharedPreferencesProvider)
        .requireValue
        .setBool(warpConsentGiven, true);
    state = state.copyWith(consentGiven: true);
    await generateWarpConfig();
  }

  Future<void> generateWarpConfig() async {
    if (state.configGeneration.isLoading) return;
    state = state.copyWith(configGeneration: const AsyncLoading());
    final result = await AsyncValue.guard(
      () async => await ref
          .read(configOptionRepositoryProvider)
          .generateWarpConfig()
          .getOrElse((l) {
        loggy.warning("error generating warp config: $l", l);
        throw l;
      }).run(),
    );
    state = state.copyWith(configGeneration: result);
  }

  static const warpConsentGiven = "warp_consent_given";
}

@freezed
class WarpOptions with _$WarpOptions {
  const factory WarpOptions({
    required bool consentGiven,
    required AsyncValue<String> configGeneration,
  }) = _WarpOptions;
}
