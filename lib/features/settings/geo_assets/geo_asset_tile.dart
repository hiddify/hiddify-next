import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/domain/rules/geo_asset.dart';
import 'package:hiddify/domain/rules/geo_asset_failure.dart';
import 'package:hiddify/features/settings/geo_assets/geo_assets_notifier.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hiddify/utils/async_mutation.dart';
import 'package:hiddify/utils/date_time_formatter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:humanizer/humanizer.dart';

class GeoAssetTile extends HookConsumerWidget {
  GeoAssetTile(GeoAssetWithFileSize geoAssetWithFileSize, {super.key})
      : geoAsset = geoAssetWithFileSize.$1,
        size = geoAssetWithFileSize.$2;

  final GeoAsset geoAsset;
  final int? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final fileMissing = size == null;

    final updateMutation = useMutation(
      initialOnFailure: (err) {
        if (err case GeoAssetNoUpdateAvailable()) {
          CustomToast(t.failure.geoAssets.notUpdate).show(context);
        } else {
          CustomAlertDialog.fromErr(
            t.presentError(err, action: t.settings.geoAssets.failureMsg),
          ).show(context);
        }
      },
      initialOnSuccess: () =>
          CustomToast.success(t.settings.geoAssets.successMsg).show(context),
    );

    return ListTile(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: geoAsset.name),
            if (geoAsset.providerName.isNotBlank)
              TextSpan(text: " (${geoAsset.providerName})"),
          ],
        ),
      ),
      isThreeLine: true,
      subtitle: updateMutation.state.isInProgress
          ? const LinearProgressIndicator()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (geoAsset.version.isNotNullOrBlank)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Text(
                      t.settings.geoAssets.version(version: geoAsset.version!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox(),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (fileMissing)
                          TextSpan(
                            text: t.settings.geoAssets.fileMissing,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        else
                          TextSpan(text: size?.bytes().toString()),
                        if (geoAsset.lastCheck != null) ...[
                          const TextSpan(text: " • "),
                          TextSpan(text: geoAsset.lastCheck!.format()),
                        ],
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      selected: geoAsset.active,
      onTap: () async {
        await ref
            .read(geoAssetsNotifierProvider.notifier)
            .markAsActive(geoAsset);
      },
      trailing: PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              enabled: !updateMutation.state.isInProgress,
              onTap: () {
                if (updateMutation.state.isInProgress) {
                  return;
                }
                updateMutation.setFuture(
                  ref
                      .read(geoAssetsNotifierProvider.notifier)
                      .updateGeoAsset(geoAsset),
                );
              },
              child: fileMissing
                  ? Text(t.settings.geoAssets.download)
                  : Text(t.settings.geoAssets.update),
            ),
          ];
        },
      ),
    );
  }
}
