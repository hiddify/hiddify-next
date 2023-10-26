import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_settings_tiles.g.dart';

@riverpod
Future<bool> isIgnoringBatteryOptimizations(
  IsIgnoringBatteryOptimizationsRef ref,
) async =>
    ref
        .watch(platformServicesProvider)
        .isIgnoringBatteryOptimizations()
        .getOrElse((l) => false)
        .run();

class PlatformSettingsTiles extends HookConsumerWidget {
  const PlatformSettingsTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final isIgnoringBatteryOptimizations =
        ref.watch(isIgnoringBatteryOptimizationsProvider);

    ListTile buildIgnoreTile(bool enabled) => ListTile(
          title: Text(t.settings.general.ignoreBatteryOptimizations),
          subtitle: Text(t.settings.general.ignoreBatteryOptimizationsMsg),
          leading: const Icon(Icons.running_with_errors),
          enabled: enabled,
          onTap: () async {
            await ref
                .read(platformServicesProvider)
                .requestIgnoreBatteryOptimizations()
                .run();
            await Future.delayed(const Duration(seconds: 1));
            ref.invalidate(isIgnoringBatteryOptimizationsProvider);
          },
        );

    return Column(
      children: [
        if (Platform.isAndroid)
          switch (isIgnoringBatteryOptimizations) {
            AsyncData(:final value) when value == false =>
              buildIgnoreTile(true),
            AsyncData(:final value) when value == true => const SizedBox(),
            _ => buildIgnoreTile(false),
          },
      ],
    );
  }
}
