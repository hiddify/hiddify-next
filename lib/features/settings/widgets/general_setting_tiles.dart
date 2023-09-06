import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/features/settings/widgets/theme_mode_switch_button.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GeneralSettingTiles extends HookConsumerWidget {
  const GeneralSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final locale = ref.watch(localeProvider);

    final theme = ref.watch(themeProvider);

    return Column(
      children: [
        ListTile(
          title: Text(t.settings.general.locale),
          subtitle: Text(
            LocaleNamesLocalizationsDelegate.nativeLocaleNames[locale.name] ??
                locale.name,
          ),
          leading: const Icon(Icons.language),
          onTap: () async {
            final selectedLocale = await showDialog<AppLocale>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(t.settings.general.locale),
                  children: AppLocale.values
                      .map(
                        (e) => RadioListTile(
                          title: Text(
                            LocaleNamesLocalizationsDelegate
                                    .nativeLocaleNames[e.name] ??
                                e.name,
                          ),
                          value: e,
                          groupValue: locale,
                          onChanged: (e) => context.pop(e),
                        ),
                      )
                      .toList(),
                );
              },
            );
            if (selectedLocale != null) {
              await ref.read(localeProvider.notifier).update(selectedLocale);
            }
          },
        ),
        ListTile(
          title: Text(t.settings.general.themeMode),
          subtitle: Text(
            switch (theme.mode) {
              ThemeMode.system => t.settings.general.themeModes.system,
              ThemeMode.light => t.settings.general.themeModes.light,
              ThemeMode.dark => t.settings.general.themeModes.dark,
            },
          ),
          trailing: ThemeModeSwitch(
            themeMode: theme.mode,
            onChanged: ref.read(themeModeProvider.notifier).update,
          ),
          leading: const Icon(Icons.light_mode),
          onTap: () async {
            await ref.read(themeModeProvider.notifier).update(
                  Theme.of(context).brightness == Brightness.light
                      ? ThemeMode.dark
                      : ThemeMode.light,
                );
          },
        ),
        SwitchListTile(
          title: Text(t.settings.general.trueBlack),
          value: theme.trueBlack,
          onChanged: ref.read(trueBlackThemeProvider.notifier).update,
        ),
        if (PlatformUtils.isDesktop) ...[
          SwitchListTile(
            title: Text(t.settings.general.silentStart),
            value: ref.watch(silentStartProvider),
            onChanged: (value) async {
              await ref.read(silentStartProvider.notifier).update(value);
            },
          ),
        ],
      ],
    );
  }
}
