import 'package:dio/dio.dart';
import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/data/repository/repository.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => AppDatabase.connect();

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) =>
    throw UnimplementedError('sharedPreferences must be overridden');

// TODO: set options for dio
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) => Dio();

@Riverpod(keepAlive: true)
ProfilesDao profilesDao(ProfilesDaoRef ref) => ProfilesDao(
      ref.watch(appDatabaseProvider),
    );

@Riverpod(keepAlive: true)
ClashFacade clashFacade(ClashFacadeRef ref) => ClashFacadeImpl(
      clashService: ref.watch(clashServiceProvider),
      filesEditor: ref.watch(filesEditorServiceProvider),
    );

@Riverpod(keepAlive: true)
ProfilesRepository profilesRepository(ProfilesRepositoryRef ref) =>
    ProfilesRepositoryImpl(
      profilesDao: ref.watch(profilesDaoProvider),
      filesEditor: ref.watch(filesEditorServiceProvider),
      clashFacade: ref.watch(clashFacadeProvider),
      dio: ref.watch(dioProvider),
    );
