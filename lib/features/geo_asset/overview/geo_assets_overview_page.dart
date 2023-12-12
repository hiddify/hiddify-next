import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/geo_asset/overview/geo_assets_overview_notifier.dart';
import 'package:hiddify/features/geo_asset/widget/geo_asset_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GeoAssetsOverviewPage extends HookConsumerWidget {
  const GeoAssetsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final state = ref.watch(geoAssetsOverviewNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(t.settings.geoAssets.pageTitle),
            pinned: true,
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(t.settings.geoAssets.addRecommended),
                      onTap: () {
                        ref
                            .read(geoAssetsOverviewNotifierProvider.notifier)
                            .addRecommended();
                      },
                    ),
                  ];
                },
              ),
            ],
          ),
          if (state case AsyncData(value: final geoAssets))
            SliverPinnedHeader(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: geoAssets
                        .where((e) => e.$1.active && e.$2 == null)
                        .isNotEmpty
                    ? const MissingRoutingAssetsCard()
                    : const SizedBox(),
              ),
            ),
          switch (state) {
            AsyncData(value: final geoAssets) => SliverList.builder(
                itemBuilder: (context, index) {
                  final geoAsset = geoAssets[index];
                  return GeoAssetTile(
                    geoAsset,
                    onMarkAsActive: () => ref
                        .read(geoAssetsOverviewNotifierProvider.notifier)
                        .markAsActive(geoAsset.$1),
                  );
                },
                itemCount: geoAssets.length,
              ),
            _ => const SliverToBoxAdapter(),
          },
        ],
      ),
    );
  }
}

class MissingRoutingAssetsCard extends HookConsumerWidget {
  const MissingRoutingAssetsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.lightbulb),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(t.settings.geoAssets.missingGeoAssetsMsg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
