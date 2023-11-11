import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/data/repository/config_options_store.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:humanizer/humanizer.dart';

class ConfigOptionsPage extends HookConsumerWidget {
  const ConfigOptionsPage({super.key});

  static final _default = ConfigOptions.initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final options = ref.watch(configPreferencesProvider);
    final serviceMode = ref.watch(serviceModeStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.config.pageTitle),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(t.general.addToClipboard),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: options.format()),
                    );
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(t.settings.config.logLevel),
            subtitle: Text(options.logLevel.name.toUpperCase()),
            onTap: () async {
              final logLevel = await SettingsPickerDialog(
                title: t.settings.config.logLevel,
                selected: options.logLevel,
                options: LogLevel.choices,
                getTitle: (e) => e.name.toUpperCase(),
                resetValue: _default.logLevel,
              ).show(context);
              if (logLevel == null) return;
              await ref.read(logLevelStore.notifier).update(logLevel);
            },
          ),
          const SettingsDivider(),
          SettingsSection(t.settings.config.section.route),
          // SwitchListTile(
          //   title: Text(t.settings.config.bypassLan),
          //   value: options.bypassLan,
          //   onChanged: ref.read(bypassLanStore.notifier).update,
          // ),
          SwitchListTile(
            title: Text(t.settings.config.resolveDestination),
            value: options.resolveDestination,
            onChanged: ref.read(resolveDestinationStore.notifier).update,
          ),
          ListTile(
            title: Text(t.settings.config.ipv6Mode),
            subtitle: Text(options.ipv6Mode.present(t)),
            onTap: () async {
              final ipv6Mode = await SettingsPickerDialog(
                title: t.settings.config.ipv6Mode,
                selected: options.ipv6Mode,
                options: IPv6Mode.values,
                getTitle: (e) => e.present(t),
                resetValue: _default.ipv6Mode,
              ).show(context);
              if (ipv6Mode == null) return;
              await ref.read(ipv6ModeStore.notifier).update(ipv6Mode);
            },
          ),
          const SettingsDivider(),
          SettingsSection(t.settings.config.section.dns),
          ListTile(
            title: Text(t.settings.config.remoteDnsAddress),
            subtitle: Text(options.remoteDnsAddress),
            onTap: () async {
              final url = await SettingsInputDialog(
                title: t.settings.config.remoteDnsAddress,
                initialValue: options.remoteDnsAddress,
                resetValue: _default.remoteDnsAddress,
              ).show(context);
              if (url == null || url.isEmpty) return;
              await ref.read(remoteDnsAddressStore.notifier).update(url);
            },
          ),
          ListTile(
            title: Text(t.settings.config.remoteDnsDomainStrategy),
            subtitle: Text(options.remoteDnsDomainStrategy.displayName),
            onTap: () async {
              final domainStrategy = await SettingsPickerDialog(
                title: t.settings.config.remoteDnsDomainStrategy,
                selected: options.remoteDnsDomainStrategy,
                options: DomainStrategy.values,
                getTitle: (e) => e.displayName,
                resetValue: _default.remoteDnsDomainStrategy,
              ).show(context);
              if (domainStrategy == null) return;
              await ref
                  .read(remoteDnsDomainStrategyStore.notifier)
                  .update(domainStrategy);
            },
          ),
          ListTile(
            title: Text(t.settings.config.directDnsAddress),
            subtitle: Text(options.directDnsAddress),
            onTap: () async {
              final url = await SettingsInputDialog(
                title: t.settings.config.directDnsAddress,
                initialValue: options.directDnsAddress,
                resetValue: _default.directDnsAddress,
              ).show(context);
              if (url == null || url.isEmpty) return;
              await ref.read(directDnsAddressStore.notifier).update(url);
            },
          ),
          ListTile(
            title: Text(t.settings.config.directDnsDomainStrategy),
            subtitle: Text(options.directDnsDomainStrategy.displayName),
            onTap: () async {
              final domainStrategy = await SettingsPickerDialog(
                title: t.settings.config.directDnsDomainStrategy,
                selected: options.directDnsDomainStrategy,
                options: DomainStrategy.values,
                getTitle: (e) => e.displayName,
                resetValue: _default.directDnsDomainStrategy,
              ).show(context);
              if (domainStrategy == null) return;
              await ref
                  .read(directDnsDomainStrategyStore.notifier)
                  .update(domainStrategy);
            },
          ),
          // SwitchListTile(
          //   title: Text(t.settings.config.enableFakeDns),
          //   value: options.enableFakeDns,
          //   onChanged: ref.read(enableFakeDnsStore.notifier).update,
          // ),
          const SettingsDivider(),
          SettingsSection(t.settings.config.section.inbound),
          // if (PlatformUtils.isDesktop) ...[
          //   SwitchListTile(
          //     title: Text(t.settings.config.enableTun),
          //     value: options.enableTun,
          //     onChanged: ref.read(enableTunStore.notifier).update,
          //   ),
          //   SwitchListTile(
          //     title: Text(t.settings.config.setSystemProxy),
          //     value: options.setSystemProxy,
          //     onChanged: ref.read(setSystemProxyStore.notifier).update,
          //   ),
          // ],
          ListTile(
            title: Text(t.settings.config.serviceMode),
            subtitle: Text(serviceMode.present(t)),
            onTap: () async {
              final pickedMode = await SettingsPickerDialog(
                title: t.settings.config.serviceMode,
                selected: serviceMode,
                options: ServiceMode.choices,
                getTitle: (e) => e.present(t),
                resetValue: ServiceMode.defaultMode,
              ).show(context);
              if (pickedMode == null) return;
              await ref
                  .read(serviceModeStoreProvider.notifier)
                  .update(pickedMode);
            },
          ),
          SwitchListTile(
            title: Text(t.settings.config.strictRoute),
            value: options.strictRoute,
            onChanged: ref.read(strictRouteStore.notifier).update,
          ),
          ListTile(
            title: Text(t.settings.config.tunImplementation),
            subtitle: Text(options.tunImplementation.name),
            onTap: () async {
              final tunImplementation = await SettingsPickerDialog(
                title: t.settings.config.tunImplementation,
                selected: options.tunImplementation,
                options: TunImplementation.values,
                getTitle: (e) => e.name,
                resetValue: _default.tunImplementation,
              ).show(context);
              if (tunImplementation == null) return;
              await ref
                  .read(tunImplementationStore.notifier)
                  .update(tunImplementation);
            },
          ),
          ListTile(
            title: Text(t.settings.config.mixedPort),
            subtitle: Text(options.mixedPort.toString()),
            onTap: () async {
              final mixedPort = await SettingsInputDialog(
                title: t.settings.config.mixedPort,
                initialValue: options.mixedPort,
                resetValue: _default.mixedPort,
                validator: isPort,
                mapTo: int.tryParse,
                digitsOnly: true,
              ).show(context);
              if (mixedPort == null) return;
              await ref.read(mixedPortStore.notifier).update(mixedPort);
            },
          ),
          ListTile(
            title: Text(t.settings.config.localDnsPort),
            subtitle: Text(options.localDnsPort.toString()),
            onTap: () async {
              final localDnsPort = await SettingsInputDialog(
                title: t.settings.config.localDnsPort,
                initialValue: options.localDnsPort,
                resetValue: _default.localDnsPort,
                validator: isPort,
                mapTo: int.tryParse,
                digitsOnly: true,
              ).show(context);
              if (localDnsPort == null) return;
              await ref.read(localDnsPortStore.notifier).update(localDnsPort);
            },
          ),
          const SettingsDivider(),
          SettingsSection(t.settings.config.section.misc),
          ListTile(
            title: Text(t.settings.config.connectionTestUrl),
            subtitle: Text(options.connectionTestUrl),
            onTap: () async {
              final url = await SettingsInputDialog(
                title: t.settings.config.connectionTestUrl,
                initialValue: options.connectionTestUrl,
                resetValue: _default.connectionTestUrl,
              ).show(context);
              if (url == null || url.isEmpty || !isUrl(url)) return;
              await ref.read(connectionTestUrlStore.notifier).update(url);
            },
          ),
          ListTile(
            title: Text(t.settings.config.urlTestInterval),
            subtitle: Text(
              options.urlTestInterval.toApproximateTime(isRelativeToNow: false),
            ),
            onTap: () async {
              final urlTestInterval = await SettingsSliderDialog(
                title: t.settings.config.urlTestInterval,
                initialValue: options.urlTestInterval.inMinutes.toDouble(),
                resetValue: _default.urlTestInterval.inMinutes.toDouble(),
                min: 1,
                max: 60,
                divisions: 60,
                labelGen: (value) => Duration(minutes: value.toInt())
                    .toApproximateTime(isRelativeToNow: false),
              ).show(context);
              if (urlTestInterval == null) return;
              await ref
                  .read(urlTestIntervalStore.notifier)
                  .update(Duration(minutes: urlTestInterval.toInt()));
            },
          ),
          ListTile(
            title: Text(t.settings.config.clashApiPort),
            subtitle: Text(options.clashApiPort.toString()),
            onTap: () async {
              final clashApiPort = await SettingsInputDialog(
                title: t.settings.config.clashApiPort,
                initialValue: options.clashApiPort,
                resetValue: _default.clashApiPort,
                validator: isPort,
                mapTo: int.tryParse,
                digitsOnly: true,
              ).show(context);
              if (clashApiPort == null) return;
              await ref.read(clashApiPortStore.notifier).update(clashApiPort);
            },
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
