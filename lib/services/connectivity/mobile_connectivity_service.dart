import 'package:flutter/services.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/services/connectivity/connectivity_service.dart';
import 'package:hiddify/services/notification/notification.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

// TODO: rewrite
class MobileConnectivityService
    with InfraLogger
    implements ConnectivityService {
  MobileConnectivityService(this.singbox, this.notifications);

  final SingboxService singbox;
  final NotificationService notifications;

  late final EventChannel _statusChannel;
  late final EventChannel _alertsChannel;
  late final ValueStream<ConnectionStatus> _connectionStatus;

  static CoreServiceFailure fromServiceAlert(String key, String? message) {
    return switch (key) {
      "EmptyConfiguration" => InvalidConfig(message),
      "StartCommandServer" ||
      "CreateService" =>
        CoreServiceCreateFailure(message),
      "StartService" => CoreServiceStartFailure(message),
      _ => const CoreServiceOtherFailure(),
    };
  }

  static ConnectionStatus fromServiceEvent(dynamic event) {
    final status = event['status'] as String;
    late ConnectionStatus connectionStatus;
    switch (status) {
      case "Stopped":
        final failure = event["failure"] as String?;
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

  @override
  Future<void> init() async {
    loggy.debug("initializing");
    _statusChannel = const EventChannel("com.hiddify.app/service.status");
    _alertsChannel = const EventChannel("com.hiddify.app/service.alerts");
    final status =
        _statusChannel.receiveBroadcastStream().map(fromServiceEvent);
    final alerts =
        _alertsChannel.receiveBroadcastStream().map(fromServiceEvent);
    _connectionStatus =
        ValueConnectableStream(Rx.merge([status, alerts])).autoConnect();
    await _connectionStatus.first;
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() => _connectionStatus;

  @override
  Future<void> connect() async {
    loggy.debug("connecting");
    await notifications.grantPermission();
    await singbox.start().getOrElse((l) => throw l).run();
  }

  @override
  Future<void> disconnect() async {
    loggy.debug("disconnecting");
    await singbox.stop().getOrElse((l) => throw l).run();
  }
}
