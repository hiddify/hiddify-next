import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/theme/theme.dart';
import 'package:hiddify/features/settings/widgets/theme_mode_switch_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AppearanceSettingTiles extends HookConsumerWidget {
  const AppearanceSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final theme = ref.watch(themeControllerProvider);
    final themeController = ref.watch(themeControllerProvider.notifier);

    return Column(
      children: [
        ListTile(
          title: Text(t.settings.appearance.themeMode.titleCase),
          subtitle: Text(
            switch (theme.themeMode) {
              ThemeMode.system => t.settings.appearance.themeModes.system,
              ThemeMode.light => t.settings.appearance.themeModes.light,
              ThemeMode.dark => t.settings.appearance.themeModes.dark,
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
          title: Text(t.settings.appearance.trueBlack.titleCase),
          value: theme.trueBlack,
          onChanged: (value) {
            themeController.change(trueBlack: value);
          },
        ),
      ],
    );
  }
}
