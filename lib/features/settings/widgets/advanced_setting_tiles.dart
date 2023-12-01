import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/general_pref_tiles.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdvancedSettingTiles extends HookConsumerWidget {
  const AdvancedSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final debug = ref.watch(debugModeNotifierProvider);
    final perAppProxy = ref.watch(perAppProxyModeNotifierProvider).enabled;
    final disableMemoryLimit = ref.watch(disableMemoryLimitProvider);

    return Column(
      children: [
        const RegionPrefTile(),
        ListTile(
          title: Text(t.settings.config.pageTitle),
          leading: const Icon(Icons.edit_document),
          onTap: () async {
            await const ConfigOptionsRoute().push(context);
          },
        ),
        ListTile(
          title: Text(t.settings.geoAssets.pageTitle),
          leading: const Icon(Icons.folder),
          onTap: () async {
            await const GeoAssetsRoute().push(context);
          },
        ),
        if (Platform.isAndroid) ...[
          ListTile(
            title: Text(t.settings.network.perAppProxyPageTitle),
            leading: const Icon(Icons.apps),
            trailing: Switch(
              value: perAppProxy,
              onChanged: (value) async {
                final newMode =
                    perAppProxy ? PerAppProxyMode.off : PerAppProxyMode.exclude;
                await ref
                    .read(perAppProxyModeNotifierProvider.notifier)
                    .update(newMode);
                if (!perAppProxy && context.mounted) {
                  await const PerAppProxyRoute().push(context);
                }
              },
            ),
            onTap: () async {
              if (!perAppProxy) {
                await ref
                    .read(perAppProxyModeNotifierProvider.notifier)
                    .update(PerAppProxyMode.exclude);
              }
              if (context.mounted) await const PerAppProxyRoute().push(context);
            },
          ),
        ],
        SwitchListTile(
          title: Text(t.settings.advanced.debugMode),
          value: debug,
          secondary: const Icon(Icons.bug_report),
          onChanged: (value) async {
            if (value) {
              await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t.settings.advanced.debugMode),
                    content: Text(t.settings.advanced.debugModeMsg),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(true),
                        child: Text(
                          MaterialLocalizations.of(context).okButtonLabel,
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            await ref.read(debugModeNotifierProvider.notifier).update(value);
          },
        ),
        SwitchListTile(
          title: Text(t.settings.advanced.memoryLimit),
          value: !disableMemoryLimit,
          onChanged: (value) async {
            await ref.read(disableMemoryLimitProvider.notifier).update(!value);
          },
        ),
      ],
    );
  }
}
