import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/domain/rules/geo_asset_failure.dart';
import 'package:hiddify/domain/rules/geo_assets_repository.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watcher/watcher.dart';

class GeoAssetsRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements GeoAssetsRepository {
  GeoAssetsRepositoryImpl({
    required this.geoAssetsDao,
    required this.dio,
    required this.filesEditor,
  });

  final GeoAssetsDao geoAssetsDao;
  final Dio dio;
  final FilesEditorService filesEditor;

  @override
  TaskEither<GeoAssetFailure, ({GeoAsset geoip, GeoAsset geosite})>
      getActivePair() {
    return exceptionHandler(
      () async {
        final geoip = await geoAssetsDao.getActive(GeoAssetType.geoip);
        final geosite = await geoAssetsDao.getActive(GeoAssetType.geosite);
        if (geoip == null || geosite == null) {
          return left(const GeoAssetFailure.activeAssetNotFound());
        }
        return right((geoip: geoip, geosite: geosite));
      },
      GeoAssetFailure.unexpected,
    );
  }

  @override
  Stream<Either<GeoAssetFailure, List<GeoAssetWithFileSize>>> watchAll() {
    final persistedStream = geoAssetsDao.watchAll();
    final filesStream = _watchGeoFiles();

    return Rx.combineLatest2(
      persistedStream,
      filesStream,
      (assets, files) => assets.map(
        (e) {
          final path = filesEditor.geoAssetPath(e.providerName, e.fileName);
          final file = files.firstOrNullWhere((e) => e.path == path);
          final stat = file?.statSync();
          return (e, stat?.size);
        },
      ).toList(),
    ).handleExceptions(GeoAssetUnexpectedFailure.new);
  }

  Iterable<File> _geoFiles = [];
  Stream<Iterable<File>> _watchGeoFiles() async* {
    yield await _readGeoFiles();
    yield* Watcher(
      filesEditor.geoAssetsDir.path,
      pollingDelay: const Duration(seconds: 1),
    ).events.asyncMap((event) async {
      await _readGeoFiles();
      return _geoFiles;
    });
  }

  Future<Iterable<File>> _readGeoFiles() async {
    return _geoFiles = Directory(filesEditor.geoAssetsDir.path)
        .listSync()
        .whereType<File>()
        .where((e) => e.extension == '.db');
  }

  @override
  TaskEither<GeoAssetFailure, Unit> update(GeoAsset geoAsset) {
    return exceptionHandler(
      () async {
        loggy.debug(
          "checking latest release of [${geoAsset.name}] on [${geoAsset.repositoryUrl}]",
        );
        final response = await dio.get<Map>(geoAsset.repositoryUrl);
        if (response.statusCode != 200 || response.data == null) {
          return left(
            GeoAssetFailure.unexpected("invalid response", StackTrace.current),
          );
        }

        final path =
            filesEditor.geoAssetPath(geoAsset.providerName, geoAsset.name);
        final tagName = response.data!['tag_name'] as String;
        loggy.debug("latest release of [${geoAsset.name}]: [$tagName]");
        if (tagName == geoAsset.version && await File(path).exists()) {
          await geoAssetsDao.edit(geoAsset.copyWith(lastCheck: DateTime.now()));
          return left(const GeoAssetFailure.noUpdateAvailable());
        }

        final assets = (response.data!['assets'] as List)
            .whereType<Map<String, dynamic>>();
        final asset =
            assets.firstOrNullWhere((e) => e["name"] == geoAsset.name);
        if (asset == null) {
          return left(
            GeoAssetFailure.unexpected(
              "couldn't find [${geoAsset.name}] on [${geoAsset.repositoryUrl}]",
              StackTrace.current,
            ),
          );
        }

        final downloadUrl = asset["browser_download_url"] as String;
        loggy.debug("[${geoAsset.name}] download url: [$downloadUrl]");
        final tempPath = "$path.tmp";
        await File(path).parent.create(recursive: true);
        await dio.download(downloadUrl, tempPath);
        await File(tempPath).rename(path);

        await geoAssetsDao.edit(
          geoAsset.copyWith(
            version: tagName,
            lastCheck: DateTime.now(),
          ),
        );

        return right(unit);
      },
      GeoAssetFailure.unexpected,
    );
  }

  @override
  TaskEither<GeoAssetFailure, Unit> markAsActive(GeoAsset geoAsset) {
    return exceptionHandler(
      () async {
        await geoAssetsDao.edit(geoAsset.copyWith(active: true));
        return right(unit);
      },
      GeoAssetFailure.unexpected,
    );
  }
}
