import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_data_source.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_path_resolver.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_repository.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geo_asset_data_providers.g.dart';

@Riverpod(keepAlive: true)
Future<GeoAssetRepository> geoAssetRepository(GeoAssetRepositoryRef ref) async {
  final repo = GeoAssetRepositoryImpl(
    geoAssetDataSource: ref.watch(geoAssetDataSourceProvider),
    geoAssetPathResolver: ref.watch(geoAssetPathResolverProvider),
    dio: ref.watch(dioProvider),
  );
  await repo.init().getOrElse((l) => throw l).run();
  return repo;
}

@Riverpod(keepAlive: true)
GeoAssetDataSource geoAssetDataSource(GeoAssetDataSourceRef ref) {
  return GeoAssetsDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
GeoAssetPathResolver geoAssetPathResolver(GeoAssetPathResolverRef ref) {
  return GeoAssetPathResolver(
    ref.watch(filesEditorServiceProvider).dirs.workingDir,
  );
}
