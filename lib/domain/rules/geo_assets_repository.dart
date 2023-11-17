import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/domain/rules/geo_asset_failure.dart';

abstract interface class GeoAssetsRepository {
  TaskEither<GeoAssetFailure, ({GeoAsset geoip, GeoAsset geosite})>
      getActivePair();

  Stream<Either<GeoAssetFailure, List<GeoAssetWithFileSize>>> watchAll();

  TaskEither<GeoAssetFailure, Unit> update(GeoAsset geoAsset);

  TaskEither<GeoAssetFailure, Unit> markAsActive(GeoAsset geoAsset);
}
