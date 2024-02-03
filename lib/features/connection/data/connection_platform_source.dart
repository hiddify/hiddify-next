import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:hiddify/core/utils/ffi_utils.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:posix/posix.dart';
import 'package:win32/win32.dart';

abstract interface class ConnectionPlatformSource {
  Future<bool> checkPrivilege();
  Future<bool> activateTunnel();
  Future<bool> deactivateTunnel();
}

class ConnectionPlatformSourceImpl
    with InfraLogger
    implements ConnectionPlatformSource {
  @override
  Future<bool> checkPrivilege() async {
    try {
      if (Platform.isWindows) {
        bool isElevated = false;
        withMemory<void, Uint32>(sizeOf<Uint32>(), (phToken) {
          withMemory<void, Uint32>(sizeOf<Uint32>(), (pReturnedSize) {
            withMemory<void, _TokenElevation>(sizeOf<_TokenElevation>(),
                (pElevation) {
              if (OpenProcessToken(
                    GetCurrentProcess(),
                    TOKEN_QUERY,
                    phToken.cast(),
                  ) ==
                  1) {
                if (GetTokenInformation(
                      phToken.value,
                      TOKEN_INFORMATION_CLASS.TokenElevation,
                      pElevation,
                      sizeOf<_TokenElevation>(),
                      pReturnedSize,
                    ) ==
                    1) {
                  isElevated = pElevation.ref.tokenIsElevated != 0;
                }
              }
              if (phToken.value != 0) {
                CloseHandle(phToken.value);
              }
            });
          });
        });
        return isElevated;
      } else if (Platform.isLinux || Platform.isMacOS) {
        final euid = geteuid();
        return euid == 0;
      } else {
        return true;
      }
    } catch (e) {
      loggy.warning("error checking privilege", e);
      return true; // return true so core handles it
    }
  }

  @override
  Future<bool> activateTunnel() async {
    if (!Platform.isWindows && !Platform.isLinux) {
      return await checkPrivilege();
    }
    try {
      final socket = await Socket.connect('127.0.0.1', 18020,
          timeout: Duration(seconds: 1));
      await socket.close();
      return await startTunnelRequest();
    } catch (error) {
      loggy.warning(
          'Tunnel Service is not running. Error: $error.--> Running...');
      return await runTunnelService();
    }
  }

  @override
  Future<bool> deactivateTunnel() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return true;
    }
    try {
      return await stopTunnelRequest();
    } catch (error) {
      loggy.error('Tunnel Service Stop Error: $error.');
      return false;
    }
  }

  Future<bool> startTunnelRequest() async {
    final params = {
      "Ipv6": false,
      "ServerPort": "2334",
      "StrictRoute": false,
      "EndpointIndependentNat": false,
      "Stack": "gvisor",
    };

    final query = mapToQueryString(params);

    try {
      final request =
          await HttpClient().get('localhost', 18020, "/start?$query");
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      loggy.debug(
          'Status Code: ${response.statusCode} ${response.reasonPhrase}');
      loggy.debug('Response Body: ${body}');
      return true;
    } catch (error) {
      loggy.error('HTTP Request Error: $error');
      return false;
    }
  }

  Future<bool> stopTunnelRequest() async {
    try {
      final request = await HttpClient().get('localhost', 18020, "/stop");
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      loggy.debug(
          'Status Code: ${response.statusCode} ${response.reasonPhrase}');
      loggy.debug('Response Body: ${body}');
      return true;
    } catch (error) {
      loggy.error('HTTP Request Error: $error');
      return false;
    }
  }

  String mapToQueryString(Map<String, dynamic> params) {
    return params.entries.map((entry) {
      final key = Uri.encodeQueryComponent(entry.key);
      final value = Uri.encodeQueryComponent(entry.value.toString());
      return '$key=$value';
    }).join('&');
  }

  Future<bool> runTunnelService() async {
    final executablePath = getTunnelServicePath();

    var command = [executablePath, "install"];
    if (Platform.isLinux) {
      command.insert(0, 'pkexec');
    }

    try {
      final result =
          await Process.run(command[0], command.sublist(1), runInShell: true);
      loggy.debug('Shell command executed: ${result.stdout} ${result.stderr}');
      return await startTunnelRequest();
    } catch (error) {
      loggy.error('Error executing shell command: $error');
      return false;
    }
  }

  static String getTunnelServicePath() {
    String fullPath = "";
    final binFolder =
        Directory(Platform.resolvedExecutable).parent.absolute.path;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      fullPath = "libcore";
    }
    if (Platform.isWindows) {
      fullPath = p.join(fullPath, "HiddifyService.exe");
    } else if (Platform.isMacOS) {
      fullPath = p.join(fullPath, "HiddifyService");
    } else {
      fullPath = p.join(fullPath, "HiddifyService");
    }

    return "$binFolder/$fullPath";
  }
}

sealed class _TokenElevation extends Struct {
  /// A nonzero value if the token has elevated privileges;
  /// otherwise, a zero value.
  @Int32()
  external int tokenIsElevated;
}
