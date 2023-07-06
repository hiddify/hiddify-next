import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/features/common/clash/clash_controller.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clash_mode.g.dart';

@Riverpod(keepAlive: true)
class ClashMode extends _$ClashMode with AppLogger {
  @override
  Future<TunnelMode?> build() async {
    final clash = ref.watch(clashFacadeProvider);
    await ref.watch(clashControllerProvider.future);
    ref.watch(prefsControllerProvider.select((value) => value.clash.mode));
    return clash
        .getConfigs()
        .map((r) => r.mode)
        .getOrElse((l) => throw l)
        .run();
  }
}
