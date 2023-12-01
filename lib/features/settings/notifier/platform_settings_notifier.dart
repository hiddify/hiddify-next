import 'package:hiddify/features/settings/data/settings_data_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_settings_notifier.g.dart';

@riverpod
class IgnoreBatteryOptimizations extends _$IgnoreBatteryOptimizations {
  @override
  Future<bool> build() async {
    return ref
        .watch(settingsRepositoryProvider)
        .isIgnoringBatteryOptimizations()
        .getOrElse((l) => false)
        .run();
  }

  Future<void> request() async {
    await ref
        .read(settingsRepositoryProvider)
        .requestIgnoreBatteryOptimizations()
        .run();
    await Future.delayed(const Duration(seconds: 1));
    ref.invalidateSelf();
  }
}
