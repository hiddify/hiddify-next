import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/misc_prefs.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/features/settings/widgets/settings_input_dialog.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class MiscellaneousSettingTiles extends HookConsumerWidget {
  const MiscellaneousSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final connectionTestUrl = ref.watch(connectionTestUrlProvider);
    final concurrentTestCount = ref.watch(concurrentTestCountProvider);
    final debug = ref.watch(debugModeProvider);

    return Column(
      children: [
        ListTile(
          title: Text(t.settings.miscellaneous.connectionTestUrl.titleCase),
          subtitle: Text(connectionTestUrl),
          onTap: () async {
            final url = await SettingsInputDialog<String>(
              title: t.settings.miscellaneous.connectionTestUrl.titleCase,
              initialValue: connectionTestUrl,
              resetValue: Defaults.connectionTestUrl,
            ).show(context);
            if (url == null || url.isEmpty || !isUrl(url)) return;
            await ref.read(connectionTestUrlProvider.notifier).update(url);
          },
        ),
        ListTile(
          title: Text(t.settings.miscellaneous.concurrentTestCount.titleCase),
          trailing: Text(concurrentTestCount.toString()),
          leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
          onTap: () async {
            final val = await SettingsInputDialog<int>(
              title: t.settings.miscellaneous.concurrentTestCount.titleCase,
              initialValue: concurrentTestCount,
              resetValue: Defaults.concurrentTestCount,
              mapTo: (value) => int.tryParse(value),
              digitsOnly: true,
            ).show(context);
            if (val == null || val < 1) return;
            await ref.read(concurrentTestCountProvider.notifier).update(val);
          },
        ),
        SwitchListTile(
          title: Text(t.settings.miscellaneous.debugMode.titleCase),
          value: debug,
          onChanged: (value) async {
            if (value) {
              await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t.settings.miscellaneous.debugMode.titleCase),
                    content: Text(
                      t.settings.miscellaneous.debugModeMsg.sentenceCase,
                    ),
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
            await ref.read(debugModeProvider.notifier).update(value);
          },
        ),
      ],
    );
  }
}
