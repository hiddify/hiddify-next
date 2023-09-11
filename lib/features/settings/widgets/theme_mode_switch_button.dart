import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeModeSwitch extends HookConsumerWidget {
  const ThemeModeSwitch({
    super.key,
    required this.themeMode,
    required this.onChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final List<bool> isSelected = <bool>[
      themeMode == ThemeMode.light,
      themeMode == ThemeMode.system,
      themeMode == ThemeMode.dark,
    ];

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int newIndex) {
        if (newIndex == 0) {
          onChanged(ThemeMode.light);
        } else if (newIndex == 1) {
          onChanged(ThemeMode.system);
        } else {
          onChanged(ThemeMode.dark);
        }
      },
      children: <Widget>[
        Icon(
          Icons.wb_sunny,
          semanticLabel: t.settings.general.themeModes.light,
        ),
        Icon(
          Icons.phone_iphone,
          semanticLabel: t.settings.general.themeModes.system,
        ),
        Icon(
          Icons.bedtime,
          semanticLabel: t.settings.general.themeModes.dark,
        ),
      ],
    );
  }
}
