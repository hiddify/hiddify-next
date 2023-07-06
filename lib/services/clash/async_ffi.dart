import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:hiddify/services/clash/async_ffi_response.dart';
import 'package:hiddify/utils/utils.dart';

// TODO: add timeout
// TODO: test and improve
mixin AsyncFFI implements LoggerMixin {
  Future<AsyncFfiResponse> runAsync(void Function(int port) run) async {
    final receivePort = ReceivePort();
    final responseFuture = receivePort.map(
      (event) {
        if (event is String) {
          receivePort.close();
          return AsyncFfiResponse.fromJson(
            jsonDecode(event) as Map<String, dynamic>,
          );
        }
        receivePort.close();
        throw Exception("unexpected data type[${event.runtimeType}]");
      },
    ).first;
    run(receivePort.sendPort.nativePort);
    return responseFuture;
  }
}
