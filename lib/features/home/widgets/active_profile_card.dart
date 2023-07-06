import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// TODO: rewrite
class ActiveProfileCard extends HookConsumerWidget {
  const ActiveProfileCard(this.profile, {super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        await const ProfilesRoute().push(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Gap(4),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    const AddProfileRoute().push(context);
                  },
                  label: Text(t.profile.add.buttonText.titleCase),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (profile.hasSubscriptionInfo) ...[
              const Divider(thickness: 0.5),
              SubscriptionInfoTile(profile.subInfo!),
            ],
          ],
        ),
      ),
    );
  }
}

class SubscriptionInfoTile extends HookConsumerWidget {
  const SubscriptionInfoTile(this.subInfo, {super.key});

  final SubscriptionInfo subInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!subInfo.isValid) return const SizedBox.shrink();
    final t = ref.watch(translationsProvider);

    final themeData = Theme.of(context);

    final updateProfileMutation = useMutation(
      initialOnFailure: (err) {
        CustomToast.error(t.presentError(err)).show(context);
      },
      initialOnSuccess: () =>
          CustomToast.success(t.profile.update.successMsg).show(context),
    );

    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      formatTrafficByteSize(
                        subInfo.consumption,
                        subInfo.total!,
                      ),
                      style: themeData.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    t.profile.subscription.traffic,
                    style: themeData.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              RemainingTrafficIndicator(subInfo.ratio),
            ],
          ),
        ),
        const Gap(8),
        IconButton(
          onPressed: () async {
            if (updateProfileMutation.state.isInProgress) return;
            updateProfileMutation.setFuture(
              ref.read(activeProfileProvider.notifier).updateProfile(),
            );
          },
          icon: const Icon(Icons.refresh, size: 44),
        ),
        const Gap(8),
        if (subInfo.isExpired)
          Text(
            t.profile.subscription.expired,
            style: themeData.textTheme.titleSmall
                ?.copyWith(color: themeData.colorScheme.error),
          )
        else if (subInfo.ratio >= 1)
          Text(
            t.profile.subscription.noTraffic,
            style: themeData.textTheme.titleSmall
                ?.copyWith(color: themeData.colorScheme.error),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatExpireDuration(subInfo.remaining),
                style: themeData.textTheme.titleSmall,
              ),
              Text(
                t.profile.subscription.remaining,
                style: themeData.textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
