import 'package:drift/drift.dart';
import 'package:hiddify/data/local/data_mappers.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/data/local/tables.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/utils/custom_loggers.dart';

part 'geo_assets_dao.g.dart';

@DriftAccessor(tables: [GeoAssetEntries])
class GeoAssetsDao extends DatabaseAccessor<AppDatabase>
    with _$GeoAssetsDaoMixin, InfraLogger {
  GeoAssetsDao(super.db);

  Future<GeoAsset?> getActive(GeoAssetType type) async {
    return (geoAssetEntries.select()
          ..where((tbl) => tbl.active.equals(true))
          ..where((tbl) => tbl.type.equalsValue(type))
          ..limit(1))
        .map(GeoAssetMapper.fromEntry)
        .getSingleOrNull();
  }

  Stream<List<GeoAsset>> watchAll() {
    return geoAssetEntries.select().map(GeoAssetMapper.fromEntry).watch();
  }

  Future<void> edit(GeoAsset patch) async {
    await transaction(
      () async {
        await (update(geoAssetEntries)..where((tbl) => tbl.id.equals(patch.id)))
            .write(patch.toCompanion());
      },
    );
  }
}
