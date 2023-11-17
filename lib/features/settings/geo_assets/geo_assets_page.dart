import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/features/settings/geo_assets/geo_asset_tile.dart';
import 'package:hiddify/features/settings/geo_assets/geo_assets_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GeoAssetsPage extends HookConsumerWidget {
  const GeoAssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final state = ref.watch(geoAssetsNotifierProvider);

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
                            .read(geoAssetsNotifierProvider.notifier)
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
                  return GeoAssetTile(geoAsset);
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
