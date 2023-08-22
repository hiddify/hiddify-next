import 'dart:io';

import 'package:loggy/loggy.dart';

class MultiLogPrinter extends LoggyPrinter {
  MultiLogPrinter(this.consolePrinter, this.filePrinter);

  final LoggyPrinter consolePrinter;
  final LoggyPrinter filePrinter;

  @override
  void onLog(LogRecord record) {
    consolePrinter.onLog(record);
    filePrinter.onLog(record);
  }
}

class FileLogPrinter extends LoggyPrinter {
  FileLogPrinter(String filePath) : _logFile = File(filePath);

  final File _logFile;

  late final _sink = _logFile.openWrite(
    mode: FileMode.writeOnly,
  );

  @override
  void onLog(LogRecord record) {
    final time = record.time.toIso8601String().split('T')[1];
    _sink.writeln("$time - $record");
  }
}
