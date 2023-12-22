import 'dart:io';

import 'package:loggy/loggy.dart';

class FileLogPrinter extends LoggyPrinter {
  FileLogPrinter(
    String filePath, {
    this.minLevel = LogLevel.debug,
  }) : _logFile = File(filePath);

  final File _logFile;
  final LogLevel minLevel;

  late final _sink = _logFile.openWrite(
    mode: FileMode.writeOnly,
  );

  @override
  void onLog(LogRecord record) {
    final time = record.time.toIso8601String().split('T')[1];
    _sink.writeln("$time - $record");
    if (record.error != null) {
      _sink.writeln(record.error);
    }
    if (record.stackTrace != null) {
      _sink.writeln(record.stackTrace);
    }
  }

  void dispose() {
    _sink.close();
  }
}
