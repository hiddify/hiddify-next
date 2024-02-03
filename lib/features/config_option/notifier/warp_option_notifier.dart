import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'warp_option_notifier.g.dart';

@Riverpod(keepAlive: true)
class WarpOptionNotifier extends _$WarpOptionNotifier {
  @override
  bool build() {
    return ref
            .read(sharedPreferencesProvider)
            .requireValue
            .getBool(warpConsentGiven) ??
        false;
  }

  Future<void> agree() async {
    await ref
        .read(sharedPreferencesProvider)
        .requireValue
        .setBool(warpConsentGiven, true);
    state = true;
  }

  static const warpConsentGiven = "warp_consent_given";
}
