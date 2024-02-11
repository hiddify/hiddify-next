import 'package:flutter/foundation.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_provider.g.dart';

@Riverpod(keepAlive: true)
DioHttpClient httpClient(HttpClientRef ref) {
  final client = DioHttpClient(
    timeout: const Duration(seconds: 15),
    userAgent: ref.watch(appInfoProvider).requireValue.userAgent,
    debug: kDebugMode,
  );

  ref.listen(
    configOptionNotifierProvider,
    (_, next) {
      if (next case AsyncData(value: final options)) {
        client.setProxyPort(options.mixedPort);
      }
    },
    fireImmediately: true,
  );
  return client;
}
