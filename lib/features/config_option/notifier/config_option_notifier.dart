import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_option_notifier.g.dart';

@Riverpod(keepAlive: true)
class ConfigOptionNotifier extends _$ConfigOptionNotifier with AppLogger {
  @override
  Future<void> build() async {}

  Future<void> exportJsonToClipboard() async {
    final map = {
      for (final option in ConfigOptions.preferences)
        ref.read(option.notifier).entry.key: ref.read(option.notifier).raw(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(map);
    await Clipboard.setData(ClipboardData(text: json));
  }

  Future<void> resetOption() async {
    for (final option in ConfigOptions.preferences) {
      await ref.read(option.notifier).reset();
    }
    ref.invalidateSelf();
  }
}
