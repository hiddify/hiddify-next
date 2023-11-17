import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hiddify/utils/riverpod_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geo_assets_notifier.g.dart';

@riverpod
class GeoAssetsNotifier extends _$GeoAssetsNotifier with AppLogger {
  @override
  Stream<List<GeoAssetWithFileSize>> build() {
    ref.disposeDelay(const Duration(seconds: 5));
    return ref
        .watch(geoAssetsRepositoryProvider)
        .watchAll()
        .map((event) => event.getOrElse((l) => throw l));
  }

  Future<void> updateGeoAsset(GeoAsset geoAsset) async {
    await ref.read(geoAssetsRepositoryProvider).update(geoAsset).getOrElse(
      (f) {
        loggy.warning("error updating profile", f);
        throw f;
      },
    ).run();
  }
}
