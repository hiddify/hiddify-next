import 'package:dio/dio.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
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
  // https://github.com/dart-lang/http/issues/1047
  // https://github.com/cfug/dio/issues/2042
  // final debug = ref.read(debugModeNotifierProvider);
  // if (debug && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
  //   dio.httpClientAdapter = NativeAdapter();
  // }
  return dio;
}
