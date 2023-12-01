import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_provider.g.dart';

@Riverpod(keepAlive: true)
Dio httpClient(HttpClientRef ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "User-Agent": ref.watch(appInfoProvider).requireValue.userAgent,
      },
    ),
  );
  final debug = ref.read(debugModeNotifierProvider);
  if (debug && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    dio.httpClientAdapter = NativeAdapter();
  }
  return dio;
}
