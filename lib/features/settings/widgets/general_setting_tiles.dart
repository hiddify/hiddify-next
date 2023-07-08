import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/core/theme/theme.dart';
import 'package:hiddify/features/settings/widgets/theme_mode_switch_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AppearanceSettingTiles extends HookConsumerWidget {
  const AppearanceSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final locale = ref.watch(localeControllerProvider);

    final theme = ref.watch(themeControllerProvider);
    final themeController = ref.watch(themeControllerProvider.notifier);

    return Column(
      children: [
        ListTile(
          title: Text(t.settings.general.locale.titleCase),
          subtitle: Text(
            LocaleNamesLocalizationsDelegate.nativeLocaleNames[locale.name] ??
                locale.name,
          ),
          onTap: () async {
            final selectedLocale = await showDialog<LocalePref>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(t.settings.general.locale.titleCase),
                  children: LocalePref.values
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
              await ref
                  .read(localeControllerProvider.notifier)
                  .change(selectedLocale);
            }
          },
        ),
        ListTile(
          title: Text(t.settings.general.themeMode.titleCase),
          subtitle: Text(
            switch (theme.themeMode) {
              ThemeMode.system => t.settings.general.themeModes.system,
              ThemeMode.light => t.settings.general.themeModes.light,
              ThemeMode.dark => t.settings.general.themeModes.dark,
            }
                .sentenceCase,
          ),
          trailing: ThemeModeSwitch(
            themeMode: theme.themeMode,
            onChanged: (value) {
              themeController.change(themeMode: value);
            },
          ),
          onTap: () async {
            await themeController.change(
              themeMode: Theme.of(context).brightness == Brightness.light
                  ? ThemeMode.dark
                  : ThemeMode.light,
            );
          },
        ),
        SwitchListTile(
          title: Text(t.settings.general.trueBlack.titleCase),
          value: theme.trueBlack,
          onChanged: (value) {
            themeController.change(trueBlack: value);
          },
        ),
      ],
    );
  }
}
