import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class NetworkSettingTiles extends HookConsumerWidget {
  const NetworkSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final prefs =
        ref.watch(prefsControllerProvider.select((value) => value.network));
    final notifier = ref.watch(prefsControllerProvider.notifier);

    return Column(
      children: [
        SwitchListTile(
          title: Text(t.settings.network.systemProxy.titleCase),
          subtitle: Text(t.settings.network.systemProxyMsg),
          value: prefs.systemProxy,
          onChanged: (value) => notifier.patchNetworkPrefs(systemProxy: value),
        ),
        SwitchListTile(
          title: Text(t.settings.network.bypassPrivateNetworks.titleCase),
          subtitle: Text(t.settings.network.bypassPrivateNetworksMsg),
          value: prefs.bypassPrivateNetworks,
          onChanged: (value) =>
              notifier.patchNetworkPrefs(bypassPrivateNetworks: value),
        ),
      ],
    );
  }
}
