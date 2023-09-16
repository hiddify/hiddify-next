import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalePrefTile extends HookConsumerWidget {
  const LocalePrefTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final locale = ref.watch(localeNotifierProvider);

    return ListTile(
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
          await ref
              .read(localeNotifierProvider.notifier)
              .update(selectedLocale);
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
