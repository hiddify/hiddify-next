import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/geo_asset/overview/geo_assets_overview_notifier.dart';
import 'package:hiddify/features/geo_asset/widget/geo_asset_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
