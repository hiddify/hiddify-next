import 'dart:math';

import 'package:intl/intl.dart';

const _units = ["B", "kB", "MB", "GB", "TB"];

({String size, String unit}) formatByteSpeed(int speed) {
  const base = 1024;
  if (speed <= 0) return (size: "0", unit: "B/s");
  final int digitGroups = (log(speed) / log(base)).round();
  return (
    size: NumberFormat("#,##0.#").format(speed / pow(base, digitGroups)),
    unit: "${_units[digitGroups]}/s",
  );
}

String formatTrafficByteSize(int consumption, int total) {
  const base = 1024;
  if (total <= 0) return "0 B / 0 B";
  final formatter = NumberFormat("#,##0.#");
  return "${formatter.format(consumption / pow(base, 3))} GB / ${formatter.format(total / pow(base, 3))} GB";
}
