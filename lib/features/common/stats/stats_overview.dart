import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/common/stats/stats_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StatsOverview extends HookConsumerWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final stats =
        ref.watch(statsNotifierProvider).asData?.value ?? CoreStatus.empty();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatCard(
            title: t.home.stats.traffic,
            firstStat: (
              label: "↑",
              data: stats.uplink.speed(),
            ),
            secondStat: (
              label: "↓",
              data: stats.downlink.speed(),
            ),
          ),
          const Gap(8),
          _StatCard(
            title: t.home.stats.trafficTotal,
            firstStat: (
              label: "↑",
              data: stats.uplinkTotal.size(),
            ),
            secondStat: (
              label: "↓",
              data: stats.downlinkTotal.size(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends HookConsumerWidget {
  const _StatCard({
    required this.title,
    required this.firstStat,
    required this.secondStat,
  });

  final String title;
  final ({String label, String data}) firstStat;
  final ({String label, String data}) secondStat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  firstStat.label,
                  style: const TextStyle(color: Colors.green),
                ),
                Text(
                  firstStat.data,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  secondStat.label,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                Text(
                  secondStat.data,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
