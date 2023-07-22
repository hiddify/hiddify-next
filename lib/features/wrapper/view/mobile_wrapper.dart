import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class MobileWrapper extends HookConsumerWidget {
  const MobileWrapper(this.navigator, {super.key});

  final Widget navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final currentIndex = getCurrentIndex(context);
    final location = GoRouterState.of(context).location;

    return Scaffold(
      key: RootScaffold.stateKey,
      body: navigator,
      drawer: SafeArea(
        child: Drawer(
          width: (MediaQuery.of(context).size.width * 0.88).clamp(0, 304),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              DrawerTile(
                label: t.settings.pageTitle.titleCase,
                icon: Icons.settings,
                selected: location == SettingsRoute.path,
                onSelect: () => const SettingsRoute().push(context),
              ),
              DrawerTile(
                label: t.logs.pageTitle.titleCase,
                icon: Icons.article,
                selected: location == LogsRoute.path,
                onSelect: () => const LogsRoute().push(context),
              ),
              DrawerTile(
                label: t.about.pageTitle.titleCase,
                icon: Icons.info,
                selected: location == AboutRoute.path,
                onSelect: () => const AboutRoute().push(context),
              ),
              const Spacer(),
              Align(
                child: Column(
                  children: [
                    Assets.images.logo.svg(width: 64),
                    const Gap(8),
                    Text(
                      t.general.appTitle.titleCase,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.power_settings_new),
            label: t.home.pageTitle.titleCase,
          ),
          NavigationDestination(
            icon: const Icon(Icons.filter_list),
            label: t.proxies.pageTitle.titleCase,
          ),
        ],
        selectedIndex: currentIndex > 1 ? 0 : currentIndex,
        onDestinationSelected: (index) => switchTab(index, context),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: Icon(icon),
      selected: selected,
      onTap: selected ? () {} : onSelect,
    );
  }
}
