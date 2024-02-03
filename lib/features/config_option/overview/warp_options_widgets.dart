import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/range.dart';
import 'package:hiddify/features/config_option/model/config_option_entity.dart';
import 'package:hiddify/features/config_option/model/config_option_patch.dart';
import 'package:hiddify/features/config_option/notifier/warp_option_notifier.dart';
import 'package:hiddify/features/settings/widgets/settings_input_dialog.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/uri_utils.dart';
import 'package:hiddify/utils/validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WarpOptionsTiles extends HookConsumerWidget {
  const WarpOptionsTiles({
    required this.options,
    required this.defaultOptions,
    required this.onChange,
    super.key,
  });

  final ConfigOptionEntity options;
  final ConfigOptionEntity defaultOptions;
  final Future<void> Function(ConfigOptionPatch patch) onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final warpPrefaceCompleted = ref.watch(warpOptionNotifierProvider);
    final canChangeOptions = warpPrefaceCompleted && options.enableWarp;

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(t.settings.config.enableWarp),
          value: options.enableWarp,
          onChanged: (value) async {
            if (!warpPrefaceCompleted) {
              final agreed = await showAdaptiveDialog<bool>(
                context: context,
                builder: (context) => const WarpLicenseAgreementModal(),
              );
              if (agreed ?? false) {
                await ref.read(warpOptionNotifierProvider.notifier).agree();
                await onChange(ConfigOptionPatch(enableWarp: value));
              }
            } else {
              await onChange(ConfigOptionPatch(enableWarp: value));
            }
          },
        ),
        ListTile(
          title: Text(t.settings.config.warpDetourMode),
          subtitle: Text(options.warpDetourMode.present(t)),
          enabled: canChangeOptions,
          onTap: () async {
            final warpDetourMode = await SettingsPickerDialog(
              title: t.settings.config.warpDetourMode,
              selected: options.warpDetourMode,
              options: WarpDetourMode.values,
              getTitle: (e) => e.present(t),
              resetValue: defaultOptions.warpDetourMode,
            ).show(context);
            if (warpDetourMode == null) return;
            await onChange(
              ConfigOptionPatch(warpDetourMode: warpDetourMode),
            );
          },
        ),
        ListTile(
          title: Text(t.settings.config.warpLicenseKey),
          subtitle: Text(
            options.warpLicenseKey.isEmpty
                ? t.general.notSet
                : options.warpLicenseKey,
          ),
          enabled: canChangeOptions,
          onTap: () async {
            final licenseKey = await SettingsInputDialog(
              title: t.settings.config.warpLicenseKey,
              initialValue: options.warpLicenseKey,
              resetValue: defaultOptions.warpLicenseKey,
            ).show(context);
            if (licenseKey == null) return;
            await onChange(ConfigOptionPatch(warpLicenseKey: licenseKey));
          },
        ),
        ListTile(
          title: Text(t.settings.config.warpCleanIp),
          subtitle: Text(options.warpCleanIp),
          enabled: canChangeOptions,
          onTap: () async {
            final warpCleanIp = await SettingsInputDialog(
              title: t.settings.config.warpCleanIp,
              initialValue: options.warpCleanIp,
              resetValue: defaultOptions.warpCleanIp,
            ).show(context);
            if (warpCleanIp == null || warpCleanIp.isBlank) return;
            await onChange(ConfigOptionPatch(warpCleanIp: warpCleanIp));
          },
        ),
        ListTile(
          title: Text(t.settings.config.warpPort),
          subtitle: Text(options.warpPort.toString()),
          enabled: canChangeOptions,
          onTap: () async {
            final warpPort = await SettingsInputDialog(
              title: t.settings.config.warpPort,
              initialValue: options.warpPort,
              resetValue: defaultOptions.warpPort,
              validator: isPort,
              mapTo: int.tryParse,
              digitsOnly: true,
            ).show(context);
            if (warpPort == null) return;
            await onChange(
              ConfigOptionPatch(warpPort: warpPort),
            );
          },
        ),
        ListTile(
          title: Text(t.settings.config.warpNoise),
          subtitle: Text(options.warpNoise.present(t)),
          enabled: canChangeOptions,
          onTap: () async {
            final warpNoise = await SettingsInputDialog(
              title: t.settings.config.warpNoise,
              initialValue: options.warpNoise.format(),
              resetValue: defaultOptions.warpNoise.format(),
            ).show(context);
            if (warpNoise == null) return;
            await onChange(
              ConfigOptionPatch(
                warpNoise: RangeWithOptionalCeil.tryParse(
                  warpNoise,
                  allowEmpty: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class WarpLicenseAgreementModal extends HookConsumerWidget {
  const WarpLicenseAgreementModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return AlertDialog.adaptive(
      title: Text(t.settings.config.warpConsent.title),
      content: Text.rich(
        t.settings.config.warpConsent.description(
          tos: (text) => TextSpan(
            text: text,
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await UriUtils.tryLaunch(
                  Uri.parse(Constants.cfWarpTermsOfService),
                );
              },
          ),
          privacy: (text) => TextSpan(
            text: text,
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await UriUtils.tryLaunch(
                  Uri.parse(Constants.cfWarpPrivacyPolicy),
                );
              },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(t.general.decline),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(t.general.agree),
        ),
      ],
    );
  }
}
