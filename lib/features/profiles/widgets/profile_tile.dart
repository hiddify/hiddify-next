import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/common/confirmation_dialogs.dart';
import 'package:hiddify/features/profiles/notifier/notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileTile extends HookConsumerWidget {
  const ProfileTile(this.profile, {super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final subInfo = profile.subInfo;

    final themeData = Theme.of(context);

    final selectActiveMutation = useMutation(
      initialOnFailure: (err) {
        CustomToast.error(t.presentError(err)).show(context);
      },
    );
    final deleteProfileMutation = useMutation(
      initialOnFailure: (err) {
        CustomToast.error(t.presentError(err)).show(context);
      },
    );

    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shadowColor: Colors.transparent,
      color: profile.active ? themeData.colorScheme.tertiaryContainer : null,
      child: InkWell(
        onTap: () {
          if (profile.active || selectActiveMutation.state.isInProgress) return;
          selectActiveMutation.setFuture(
            ref
                .read(profilesNotifierProvider.notifier)
                .selectActiveProfile(profile.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text.rich(
                      overflow: TextOverflow.ellipsis,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: profile.name,
                            style: themeData.textTheme.titleMedium,
                          ),
                          const TextSpan(text: " • "),
                          TextSpan(
                            text: t.profile.subscription.updatedTimeAgo(
                              timeago: timeago.format(profile.lastUpdate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Gap(12),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onPressed: () async {
                            // await context.push(Routes.profile(profile.id).path);
                            // TODO: temp
                            await ProfileDetailsRoute(profile.id).push(context);
                          },
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: IconButton(
                          icon: const Icon(Icons.delete_forever),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 18,
                          onPressed: () async {
                            if (deleteProfileMutation.state.isInProgress) {
                              return;
                            }
                            final deleteConfirmed =
                                await showConfirmationDialog(
                              context,
                              title: t.profile.delete.buttonText.titleCase,
                              message:
                                  t.profile.delete.confirmationMsg.sentenceCase,
                            );
                            if (deleteConfirmed) {
                              deleteProfileMutation.setFuture(
                                ref
                                    .read(profilesNotifierProvider.notifier)
                                    .deleteProfile(profile),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (subInfo?.isValid ?? false) ...[
                const Gap(2),
                Row(
                  children: [
                    if (subInfo!.isExpired)
                      Text(
                        t.profile.subscription.expired,
                        style: themeData.textTheme.titleSmall
                            ?.copyWith(color: themeData.colorScheme.error),
                      )
                    else if (subInfo.ratio >= 1)
                      Text(
                        t.profile.subscription.noTraffic,
                        style: themeData.textTheme.titleSmall?.copyWith(
                          color: themeData.colorScheme.error,
                        ),
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
                    const Gap(16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTrafficByteSize(
                              subInfo.consumption,
                              subInfo.total!,
                            ),
                            style: themeData.textTheme.titleMedium,
                          ),
                          RemainingTrafficIndicator(subInfo.ratio),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
