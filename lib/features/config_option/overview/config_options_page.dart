import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/range.dart';
import 'package:hiddify/features/config_option/model/config_option_entity.dart';
import 'package:hiddify/features/config_option/model/config_option_patch.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/features/settings/widgets/sections_widgets.dart';
import 'package:hiddify/features/settings/widgets/settings_input_dialog.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:humanizer/humanizer.dart';

class ConfigOptionsPage extends HookConsumerWidget {
  const ConfigOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final defaultOptions = ConfigOptionEntity.initial;
    final asyncOptions = ref.watch(configOptionNotifierProvider);

    Future<void> changeOption(ConfigOptionPatch patch) async {
      await ref.read(configOptionNotifierProvider.notifier).updateOption(patch);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.config.pageTitle),
        actions: [
          if (asyncOptions case AsyncData(value: final options))
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
      body: switch (asyncOptions) {
        AsyncData(value: final options) => ListView(
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
                    resetValue: defaultOptions.logLevel,
                  ).show(context);
                  if (logLevel == null) return;
                  await changeOption(ConfigOptionPatch(logLevel: logLevel));
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
                onChanged: (value) async =>
                    changeOption(ConfigOptionPatch(resolveDestination: value)),
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
                    resetValue: defaultOptions.ipv6Mode,
                  ).show(context);
                  if (ipv6Mode == null) return;
                  await changeOption(ConfigOptionPatch(ipv6Mode: ipv6Mode));
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
                    resetValue: defaultOptions.remoteDnsAddress,
                  ).show(context);
                  if (url == null || url.isEmpty) return;
                  await changeOption(ConfigOptionPatch(remoteDnsAddress: url));
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
                    resetValue: defaultOptions.remoteDnsDomainStrategy,
                  ).show(context);
                  if (domainStrategy == null) return;
                  await changeOption(
                    ConfigOptionPatch(remoteDnsDomainStrategy: domainStrategy),
                  );
                },
              ),
              ListTile(
                title: Text(t.settings.config.directDnsAddress),
                subtitle: Text(options.directDnsAddress),
                onTap: () async {
                  final url = await SettingsInputDialog(
                    title: t.settings.config.directDnsAddress,
                    initialValue: options.directDnsAddress,
                    resetValue: defaultOptions.directDnsAddress,
                  ).show(context);
                  if (url == null || url.isEmpty) return;
                  await changeOption(ConfigOptionPatch(directDnsAddress: url));
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
                    resetValue: defaultOptions.directDnsDomainStrategy,
                  ).show(context);
                  if (domainStrategy == null) return;
                  await changeOption(
                    ConfigOptionPatch(directDnsDomainStrategy: domainStrategy),
                  );
                },
              ),
              // SwitchListTile(
              //   title: Text(t.settings.config.enableFakeDns),
              //   value: options.enableFakeDns,
              //   onChanged: ref.read(enableFakeDnsStore.notifier).update,
              // ),
              const SettingsDivider(),
              SettingsSection(t.settings.config.section.inbound),
              ListTile(
                title: Text(t.settings.config.serviceMode),
                subtitle: Text(options.serviceMode.present(t)),
                onTap: () async {
                  final pickedMode = await SettingsPickerDialog(
                    title: t.settings.config.serviceMode,
                    selected: options.serviceMode,
                    options: ServiceMode.choices,
                    getTitle: (e) => e.present(t),
                    resetValue: ServiceMode.defaultMode,
                  ).show(context);
                  if (pickedMode == null) return;
                  await changeOption(
                    ConfigOptionPatch(serviceMode: pickedMode),
                  );
                },
              ),
              SwitchListTile(
                title: Text(t.settings.config.strictRoute),
                value: options.strictRoute,
                onChanged: (value) async =>
                    changeOption(ConfigOptionPatch(strictRoute: value)),
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
                    resetValue: defaultOptions.tunImplementation,
                  ).show(context);
                  if (tunImplementation == null) return;
                  await changeOption(
                    ConfigOptionPatch(tunImplementation: tunImplementation),
                  );
                },
              ),
              ListTile(
                title: Text(t.settings.config.mixedPort),
                subtitle: Text(options.mixedPort.toString()),
                onTap: () async {
                  final mixedPort = await SettingsInputDialog(
                    title: t.settings.config.mixedPort,
                    initialValue: options.mixedPort,
                    resetValue: defaultOptions.mixedPort,
                    validator: isPort,
                    mapTo: int.tryParse,
                    digitsOnly: true,
                  ).show(context);
                  if (mixedPort == null) return;
                  await changeOption(ConfigOptionPatch(mixedPort: mixedPort));
                },
              ),
              ListTile(
                title: Text(t.settings.config.localDnsPort),
                subtitle: Text(options.localDnsPort.toString()),
                onTap: () async {
                  final localDnsPort = await SettingsInputDialog(
                    title: t.settings.config.localDnsPort,
                    initialValue: options.localDnsPort,
                    resetValue: defaultOptions.localDnsPort,
                    validator: isPort,
                    mapTo: int.tryParse,
                    digitsOnly: true,
                  ).show(context);
                  if (localDnsPort == null) return;
                  await changeOption(
                    ConfigOptionPatch(localDnsPort: localDnsPort),
                  );
                },
              ),
              const SettingsDivider(),
              SettingsSection(t.settings.config.section.outbound),
              SwitchListTile(
                title: Text(t.settings.config.enableTlsFragment),
                value: options.enableTlsFragment,
                onChanged: (value) async =>
                    changeOption(ConfigOptionPatch(enableTlsFragment: value)),
              ),
              ListTile(
                title: Text(t.settings.config.tlsFragmentSize),
                subtitle: Text(options.tlsFragmentSize.format()),
                onTap: () async {
                  final range = await SettingsInputDialog(
                    title: t.settings.config.tlsFragmentSize,
                    initialValue: options.tlsFragmentSize.format(),
                    resetValue: defaultOptions.tlsFragmentSize.format(),
                  ).show(context);
                  if (range == null) return;
                  await changeOption(
                    ConfigOptionPatch(
                      tlsFragmentSize: RangeWithOptionalCeil.tryParse(range),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(t.settings.config.tlsFragmentSleep),
                subtitle: Text(options.tlsFragmentSleep.format()),
                onTap: () async {
                  final range = await SettingsInputDialog(
                    title: t.settings.config.tlsFragmentSleep,
                    initialValue: options.tlsFragmentSleep.format(),
                    resetValue: defaultOptions.tlsFragmentSleep.format(),
                  ).show(context);
                  if (range == null) return;
                  await changeOption(
                    ConfigOptionPatch(
                      tlsFragmentSleep: RangeWithOptionalCeil.tryParse(range),
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: Text(t.settings.config.enableTlsMixedSniCase),
                value: options.enableTlsMixedSniCase,
                onChanged: (value) async => changeOption(
                  ConfigOptionPatch(enableTlsMixedSniCase: value),
                ),
              ),
              SwitchListTile(
                title: Text(t.settings.config.enableTlsPadding),
                value: options.enableTlsPadding,
                onChanged: (value) async => changeOption(
                  ConfigOptionPatch(enableTlsPadding: value),
                ),
              ),
              ListTile(
                title: Text(t.settings.config.tlsPaddingSize),
                subtitle: Text(options.tlsPaddingSize.format()),
                onTap: () async {
                  final range = await SettingsInputDialog(
                    title: t.settings.config.tlsPaddingSize,
                    initialValue: options.tlsPaddingSize.format(),
                    resetValue: defaultOptions.tlsPaddingSize.format(),
                  ).show(context);
                  if (range == null) return;
                  await changeOption(
                    ConfigOptionPatch(
                      tlsPaddingSize: RangeWithOptionalCeil.tryParse(range),
                    ),
                  );
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
                    resetValue: defaultOptions.connectionTestUrl,
                  ).show(context);
                  if (url == null || url.isEmpty || !isUrl(url)) return;
                  await changeOption(ConfigOptionPatch(connectionTestUrl: url));
                },
              ),
              ListTile(
                title: Text(t.settings.config.urlTestInterval),
                subtitle: Text(
                  options.urlTestInterval
                      .toApproximateTime(isRelativeToNow: false),
                ),
                onTap: () async {
                  final urlTestInterval = await SettingsSliderDialog(
                    title: t.settings.config.urlTestInterval,
                    initialValue: options.urlTestInterval.inMinutes
                        .coerceIn(0, 60)
                        .toDouble(),
                    resetValue:
                        defaultOptions.urlTestInterval.inMinutes.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 60,
                    labelGen: (value) => Duration(minutes: value.toInt())
                        .toApproximateTime(isRelativeToNow: false),
                  ).show(context);
                  if (urlTestInterval == null) return;
                  await changeOption(
                    ConfigOptionPatch(
                      urlTestInterval:
                          Duration(minutes: urlTestInterval.toInt()),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(t.settings.config.clashApiPort),
                subtitle: Text(options.clashApiPort.toString()),
                onTap: () async {
                  final clashApiPort = await SettingsInputDialog(
                    title: t.settings.config.clashApiPort,
                    initialValue: options.clashApiPort,
                    resetValue: defaultOptions.clashApiPort,
                    validator: isPort,
                    mapTo: int.tryParse,
                    digitsOnly: true,
                  ).show(context);
                  if (clashApiPort == null) return;
                  await changeOption(
                    ConfigOptionPatch(clashApiPort: clashApiPort),
                  );
                },
              ),
              const Gap(24),
            ],
          ),
        // TODO show appropriate error/loading widgets
        _ => const SizedBox(),
      },
    );
  }
}
