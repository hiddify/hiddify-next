import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tint/tint.dart';

part 'box_log.freezed.dart';

enum LogLevel {
  trace,
  debug,
  info,
  warn,
  error,
  fatal,
  panic;

  static List<LogLevel> get choices => values.takeFirst(4);

  Color? get color => switch (this) {
        trace => Colors.lightBlueAccent,
        debug => Colors.grey,
        info => Colors.lightGreen,
        warn => Colors.orange,
        error => Colors.redAccent,
        fatal => Colors.red,
        panic => Colors.red,
      };
}

@freezed
class BoxLog with _$BoxLog {
  const factory BoxLog({
    LogLevel? level,
    DateTime? time,
    required String message,
  }) = _BoxLog;

  factory BoxLog.parse(String log) {
    log = log.strip();
    DateTime? time;
    if (log.length > 25) {
      time = DateTime.tryParse(log.substring(6, 25));
    }
    if (time != null) {
      log = log.substring(26);
    }
    final level = LogLevel.values.firstOrNullWhere(
      (e) {
        if (log.startsWith(e.name.toUpperCase())) {
          log = log.removePrefix(e.name.toUpperCase());
          return true;
        }
        return false;
      },
    );
    return BoxLog(
      level: level,
      time: time,
      message: log.trim(),
    );
  }
}
