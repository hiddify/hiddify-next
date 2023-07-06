import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    const divider = Divider(indent: 16, endIndent: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.pageTitle.titleCase),
      ),
      body: ListTileTheme(
        data: ListTileTheme.of(context).copyWith(
          contentPadding: const EdgeInsetsDirectional.only(start: 48, end: 16),
        ),
        child: ListView(
          children: [
            _SettingsSectionHeader(
              t.settings.appearance.sectionTitle.titleCase,
            ),
            const AppearanceSettingTiles(),
            divider,
            _SettingsSectionHeader(t.settings.network.sectionTitle.titleCase),
            const NetworkSettingTiles(),
            divider,
            _SettingsSectionHeader(t.settings.clash.sectionTitle.titleCase),
            const ClashSettingTiles(),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
