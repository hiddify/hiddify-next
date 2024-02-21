import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:hiddify/utils/custom_loggers.dart';

class DioHttpClient with InfraLogger {
  DioHttpClient({
    required Duration timeout,
    required String userAgent,
    required bool debug,
  }) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        headers: {"User-Agent": userAgent},
      ),
    );

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    if (debug) {
      _dio.interceptors.add(LoggyDioInterceptor(requestHeader: true));
    }
  }

  late final Dio _dio;

  void setProxyPort(int port) {
    loggy.debug("setting proxy port: [$port]");
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (url) {
          return "PROXY localhost:$port; DIRECT";
        };
        return client;
      },
    );
  }

  Future<Response<T>> get<T>(
    String url, {
    CancelToken? cancelToken,
    String? userAgent,
    ({String username, String password})? credentials,
  }) async {
    return _dio.get<T>(
      url,
      cancelToken: cancelToken,
      options: _options(url, userAgent: userAgent, credentials: credentials),
    );
  }

  Future<Response> download(
    String url,
    String path, {
    CancelToken? cancelToken,
    String? userAgent,
    ({String username, String password})? credentials,
  }) async {
    return _dio.download(
      url,
      path,
      cancelToken: cancelToken,
      options: _options(
        url,
        userAgent: userAgent,
        credentials: credentials,
      ),
    );
  }

  Options _options(
    String url, {
    String? userAgent,
    ({String username, String password})? credentials,
  }) {
    final uri = Uri.parse(url);

    String? userInfo;
    if (credentials != null) {
      userInfo = "${credentials.username}:${credentials.password}";
    } else if (uri.userInfo.isNotEmpty) {
      userInfo = uri.userInfo;
    }

    String? basicAuth;
    if (userInfo != null) {
      basicAuth = "Basic ${base64.encode(utf8.encode(userInfo))}";
    }

    return Options(
      headers: {
        if (userAgent != null) "User-Agent": userAgent,
        if (basicAuth != null) "authorization": basicAuth,
        // "Accept": "application/json",
        // "Content-Type": "application/json",
      },
    );
  }
}
