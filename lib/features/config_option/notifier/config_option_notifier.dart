import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/connection/data/connection_data_providers.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_option_notifier.g.dart';

@Riverpod(keepAlive: true)
class ConfigOptionNotifier extends _$ConfigOptionNotifier with AppLogger {
  @override
  Future<bool> build() async {
    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    final serviceSingboxOptions =
        ref.read(connectionRepositoryProvider).configOptionsSnapshot;
    ref.listen(
      ConfigOptions.singboxConfigOptions,
      (previous, next) async {
        if (!serviceRunning || serviceSingboxOptions == null) return;
        if (next case AsyncData(:final value) when next != previous) {
          if (_lastUpdate == null ||
              DateTime.now().difference(_lastUpdate!) >
                  const Duration(seconds: 3)) {
            _lastUpdate = DateTime.now();
            state = AsyncData(value != serviceSingboxOptions);
          }
        }
      },
      fireImmediately: true,
    );
    return false;
  }

  DateTime? _lastUpdate;

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
