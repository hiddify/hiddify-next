import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ClashApi with InfraLogger {
  ClashApi(int port) : address = "${Constants.localHost}:$port";

  final String address;

  late final _clashDio = Dio(
    BaseOptions(
      baseUrl: "http://$address",
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 3),
    ),
  );

  TaskEither<String, List<ClashProxy>> getProxies() {
    return TaskEither(
      () async {
        final response = await _clashDio.get("/proxies");
        if (response.statusCode != 200 || response.data == null) {
          return left(response.statusMessage ?? "");
        }
        final proxies = ((jsonDecode(response.data! as String)
                as Map<String, dynamic>)["proxies"] as Map<String, dynamic>)
            .entries
            .map(
          (e) {
            final proxyMap = (e.value as Map<String, dynamic>)
              ..putIfAbsent('name', () => e.key);
            return ClashProxy.fromJson(proxyMap);
          },
        );
        return right(proxies.toList());
      },
    );
  }

  TaskEither<String, Unit> changeProxy(String selectorName, String proxyName) {
    return TaskEither(
      () async {
        final response = await _clashDio.put(
          "/proxies/$selectorName",
          data: {"name": proxyName},
        );
        if (response.statusCode != HttpStatus.noContent) {
          return left(response.statusMessage ?? "");
        }
        return right(unit);
      },
    );
  }

  TaskEither<String, int> getProxyDelay(
    String name,
    String url, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    return TaskEither(
      () async {
        final response = await _clashDio.get<Map>(
          "/proxies/$name/delay",
          queryParameters: {
            "timeout": timeout.inMilliseconds,
            "url": url,
          },
        );
        if (response.statusCode != 200 || response.data == null) {
          return left(response.statusMessage ?? "");
        }
        return right(response.data!["delay"] as int);
      },
    );
  }

  TaskEither<String, ClashConfig> getConfigs() {
    return TaskEither(
      () async {
        final response = await _clashDio.get("/configs");
        if (response.statusCode != 200 || response.data == null) {
          return left(response.statusMessage ?? "");
        }
        final config =
            ClashConfig.fromJson(response.data as Map<String, dynamic>);
        return right(config);
      },
    );
  }

  TaskEither<String, Unit> updateConfigs(String path) {
    return TaskEither.of(unit);
  }

  TaskEither<String, Unit> patchConfigs(ClashConfig config) {
    return TaskEither(
      () async {
        final response = await _clashDio.patch(
          "/configs",
          data: config.toJson(),
        );
        if (response.statusCode != HttpStatus.noContent) {
          return left(response.statusMessage ?? "");
        }
        return right(unit);
      },
    );
  }

  Stream<ClashLog> watchLogs(LogLevel level) {
    return const Stream.empty();
  }

  Stream<ClashTraffic> watchTraffic() {
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://$address/traffic"),
    );
    return channel.stream.map(
      (event) {
        return ClashTraffic.fromJson(
          jsonDecode(event as String) as Map<String, dynamic>,
        );
      },
    );
  }

  TaskEither<String, ClashTraffic> getTraffic() {
    return TaskEither(
      () async {
        final response = await _clashDio.get<Map<String, dynamic>>("/traffic");
        if (response.statusCode != 200 || response.data == null) {
          return left(response.statusMessage ?? "");
        }
        return right(ClashTraffic.fromJson(response.data!));
      },
    );
  }
}
