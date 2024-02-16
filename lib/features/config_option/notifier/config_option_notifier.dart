import 'package:hiddify/features/config_option/data/config_option_data_providers.dart';
import 'package:hiddify/features/config_option/model/config_option_entity.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_option_notifier.g.dart';

@Riverpod(keepAlive: true)
class ConfigOptionNotifier extends _$ConfigOptionNotifier with AppLogger {
  @override
  Future<ConfigOptionEntity> build() async {
    return ref
        .watch(configOptionRepositoryProvider)
        .getConfigOption()
        .getOrElse((l) {
      loggy.error("error getting persisted options $l", l);
      throw l;
    });
  }

  Future<void> updateOption(ConfigOptionPatch patch) async {
    if (state case AsyncData(value: final options)) {
      await ref
          .read(configOptionRepositoryProvider)
          .updateConfigOption(patch)
          .map((_) => state = AsyncData(options.patch(patch)))
          .run();
    }
  }

  Future<void> resetOption() async {
    await ref.read(configOptionRepositoryProvider).resetConfigOption().run();
    ref.invalidateSelf();
  }
}
