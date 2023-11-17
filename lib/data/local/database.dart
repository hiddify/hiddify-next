import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/local/data_mappers.dart';
import 'package:hiddify/data/local/schema_versions.dart';
import 'package:hiddify/data/local/tables.dart';
import 'package:hiddify/data/local/type_converters.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(
  tables: [ProfileEntries, GeoAssetEntries],
  daos: [ProfilesDao, GeoAssetsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({required QueryExecutor connection}) : super(connection);

  AppDatabase.connect() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _prePopulateGeoAssets();
      },
      onUpgrade: stepByStep(
        // add type column to profile entries table
        // make url column nullable
        from1To2: (m, schema) async {
          await m.alterTable(
            TableMigration(
              schema.profileEntries,
              columnTransformer: {
                schema.profileEntries.type: const Constant<String>("remote"),
              },
              newColumns: [schema.profileEntries.type],
            ),
          );
        },
        from2To3: (m, schema) async {
          await m.createTable(schema.geoAssetEntries);
          await _prePopulateGeoAssets();
        },
      ),
    );
  }

  Future<void> _prePopulateGeoAssets() async {
    await transaction(() async {
      final geoAssets = defaultGeoAssets.map((e) => e.toCompanion());
      for (final geoAsset in geoAssets) {
        await into(geoAssetEntries).insert(geoAsset);
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await FilesEditorService.getDatabaseDirectory();
    final file = File(p.join(dbDir.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
