import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/core_service_failure.dart';

mixin ServiceStatus {
  ConnectionStatus mapEventToStatus(dynamic event) {
    final status = event['status'] as String;
    late ConnectionStatus connectionStatus;
    switch (status) {
      case "Stopped":
        final failure = event["alert"] as String?;
        final message = event["message"] as String?;
        connectionStatus = ConnectionStatus.disconnected(
          switch (failure) {
            null => null,
            "RequestVPNPermission" => MissingVpnPermission(message),
            "RequestNotificationPermission" =>
              MissingNotificationPermission(message),
            "EmptyConfiguration" ||
            "StartCommandServer" ||
            "CreateService" ||
            "StartService" =>
              CoreConnectionFailure(fromServiceAlert(failure, message)),
            _ => const UnexpectedConnectionFailure(),
          },
        );
      case "Starting":
        connectionStatus = const Connecting();
      case "Started":
        connectionStatus = const Connected();
      case "Stopping":
        connectionStatus = const Disconnecting();
    }
    return connectionStatus;
  }

  CoreServiceFailure fromServiceAlert(String key, String? message) {
    return switch (key) {
      "EmptyConfiguration" => InvalidConfig(message),
      "StartCommandServer" ||
      "CreateService" =>
        CoreServiceCreateFailure(message),
      "StartService" => CoreServiceStartFailure(message),
      _ => const CoreServiceOtherFailure(),
    };
  }
}
