import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/locale_extensions.dart';
import 'package:hiddify/core/localization/locale_preferences.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalePrefTile extends HookConsumerWidget {
  const LocalePrefTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final locale = ref.watch(localePreferencesProvider);

    return ListTile(
      title: Text(t.settings.general.locale),
      subtitle: Text(locale.localeName),
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
                      title: Text(e.localeName),
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
              .read(localePreferencesProvider.notifier)
              .changeLocale(selectedLocale);
        }
      },
    );
  }
}

class RegionPrefTile extends HookConsumerWidget {
  const RegionPrefTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final region = ref.watch(regionNotifierProvider);

    return ListTile(
      title: Text(t.settings.general.region),
      subtitle: Text(region.present(t)),
      leading: const Icon(Icons.my_location),
      onTap: () async {
        final selectedRegion = await showDialog<Region>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(t.settings.general.region),
              children: Region.values
                  .map(
                    (e) => RadioListTile(
                      title: Text(e.present(t)),
                      value: e,
                      groupValue: region,
                      onChanged: (e) => context.pop(e),
                    ),
                  )
                  .toList(),
            );
          },
        );
        if (selectedRegion != null) {
          await ref
              .read(regionNotifierProvider.notifier)
              .update(selectedRegion);
        }
      },
    );
  }
}

class EnableAnalyticsPrefTile extends HookConsumerWidget {
  const EnableAnalyticsPrefTile({
    super.key,
    this.onChanged,
  });

  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final autoReport = ref.watch(enableAnalyticsProvider);

    return SwitchListTile(
      title: Text(t.settings.general.enableAnalytics),
      subtitle: Text(
        t.settings.general.enableAnalyticsMsg,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      secondary: const Icon(Icons.bug_report),
      value: autoReport,
      onChanged: (value) async {
        if (onChanged != null) {
          return onChanged!(value);
        }
        return ref.read(enableAnalyticsProvider.notifier).update(value);
      },
    );
  }
}
