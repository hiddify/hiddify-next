import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/general_prefs.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/data/repository/app_repository_impl.dart';
import 'package:hiddify/data/repository/config_options_store.dart';
import 'package:hiddify/data/repository/repository.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/core_facade.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_data_providers.dart';
import 'package:hiddify/features/profile/data/profile_data_providers.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase.connect();

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError('sharedPreferences must be overridden');

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "User-Agent": ref.watch(appInfoProvider).userAgent,
      },
    ),
  );
  final debug = ref.read(debugModeNotifierProvider);
  if (debug && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    dio.httpClientAdapter = NativeAdapter();
  }
  return dio;
}

@Riverpod(keepAlive: true)
AppRepository appRepository(AppRepositoryRef ref) =>
    AppRepositoryImpl(ref.watch(dioProvider));

@riverpod
Future<ConfigOptions> configOptions(ConfigOptionsRef ref) async {
  final geoAssets = await ref
      .watch(geoAssetRepositoryProvider)
      .requireValue
      .getActivePair()
      .getOrElse((l) => throw l)
      .run();
  final geoAssetsPathResolver = ref.watch(geoAssetPathResolverProvider);

  final serviceMode = ref.watch(serviceModeStoreProvider);
  return ref.watch(configPreferencesProvider).copyWith(
        enableTun: serviceMode == ServiceMode.tun,
        setSystemProxy: serviceMode == ServiceMode.systemProxy,
        geoipPath: geoAssetsPathResolver.relativePath(
          geoAssets.geoip.providerName,
          geoAssets.geoip.fileName,
        ),
        geositePath: geoAssetsPathResolver.relativePath(
          geoAssets.geosite.providerName,
          geoAssets.geosite.fileName,
        ),
      );
}

@Riverpod(keepAlive: true)
CoreFacade coreFacade(CoreFacadeRef ref) => CoreFacadeImpl(
      ref.watch(singboxServiceProvider),
      ref.watch(filesEditorServiceProvider),
      ref.watch(geoAssetPathResolverProvider),
      ref.watch(profilePathResolverProvider),
      ref.watch(platformServicesProvider),
      ref.read(debugModeNotifierProvider),
      () => ref.read(configOptionsProvider.future),
    );
