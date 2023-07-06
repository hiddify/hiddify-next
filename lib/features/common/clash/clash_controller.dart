import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clash_controller.g.dart';

@Riverpod(keepAlive: true)
class ClashController extends _$ClashController with AppLogger {
  Profile? _oldProfile;

  @override
  Future<void> build() async {
    final clash = ref.watch(clashFacadeProvider);

    final overridesListener = ref.listen(
      prefsControllerProvider.select((value) => value.clash),
      (_, overrides) async {
        loggy.debug("new clash overrides received, patching...");
        await clash.patchOverrides(overrides).getOrElse((l) => throw l).run();
      },
    );
    final overrides = overridesListener.read();

    final activeProfile = await ref.watch(activeProfileProvider.future);
    final oldProfile = _oldProfile;
    _oldProfile = activeProfile;
    if (activeProfile != null) {
      if (oldProfile == null ||
          oldProfile.id != activeProfile.id ||
          oldProfile.lastUpdate != activeProfile.lastUpdate) {
        loggy.debug("profile changed or updated, updating clash core");
        await clash
            .changeConfigs(activeProfile.id)
            .call(clash.patchOverrides(overrides))
            .getOrElse((error) {
          loggy.warning("failed to change or patch configs, $error");
          throw error;
        }).run();
      }
    } else {
      if (oldProfile != null) {
        loggy.debug("active profile removed, resetting clash");
        await clash
            .changeConfigs(Constants.configFileName)
            .getOrElse((l) => throw l)
            .run();
      }
    }
  }
}
