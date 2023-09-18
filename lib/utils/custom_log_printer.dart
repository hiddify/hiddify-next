import 'dart:io';

import 'package:loggy/loggy.dart';

class MultiLogPrinter extends LoggyPrinter {
  MultiLogPrinter(
    this.consolePrinter,
    this.otherPrinters,
  );

  final LoggyPrinter consolePrinter;
  List<LoggyPrinter> otherPrinters;

  void addPrinter(LoggyPrinter printer) {
    otherPrinters.add(printer);
  }

  @override
  void onLog(LogRecord record) {
    consolePrinter.onLog(record);
    for (final printer in otherPrinters) {
      printer.onLog(record);
    }
  }
}

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
  }
}
