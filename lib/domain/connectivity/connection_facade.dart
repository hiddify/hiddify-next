import 'package:fpdart/fpdart.dart';
import 'package:hiddify/domain/connectivity/connection_status.dart';
import 'package:hiddify/domain/core_service_failure.dart';

abstract interface class ConnectionFacade {
  TaskEither<CoreServiceFailure, Unit> connect();

  TaskEither<CoreServiceFailure, Unit> disconnect();

  Stream<ConnectionStatus> watchConnectionStatus();
}
