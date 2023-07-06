import 'package:loggy/loggy.dart';

/// application layer logger
///
/// used in notifiers and controllers
mixin AppLogger implements LoggyType {
  @override
  Loggy<AppLogger> get loggy => Loggy<AppLogger>('🧮 $runtimeType');
}

/// presentation layer logger
///
/// used in widgets and ui
mixin PresLogger implements LoggyType {
  @override
  Loggy<PresLogger> get loggy => Loggy<PresLogger>('🏰 $runtimeType');
}

/// data layer logger
///
/// used in Repositories, DAOs, Services
mixin InfraLogger implements LoggyType {
  @override
  Loggy<InfraLogger> get loggy => Loggy<InfraLogger>('💾 $runtimeType');
}

abstract class LoggerMixin {
  LoggerMixin(this.loggy);

  final Loggy loggy;
}
