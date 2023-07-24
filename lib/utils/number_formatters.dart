import 'dart:math';

import 'package:intl/intl.dart';

const _units = ["B", "kB", "MB", "GB", "TB"];

({String size, String unit}) formatByte(int input, {int? unit}) {
  const base = 1024;
  if (input <= 0) return (size: "0", unit: _units[unit ?? 0]);
  final int digitGroups = unit ?? (log(input) / log(base)).round();
  return (
    size: NumberFormat("#,##0.#").format(input / pow(base, digitGroups)),
    unit: _units[digitGroups],
  );
}

// TODO remove
({String size, String unit}) formatByteSpeed(int speed) {
  const base = 1024;
  if (speed <= 0) return (size: "0", unit: "B/s");
  final int digitGroups = (log(speed) / log(base)).round();
  return (
    size: NumberFormat("#,##0.#").format(speed / pow(base, digitGroups)),
    unit: "${_units[digitGroups]}/s",
  );
}
