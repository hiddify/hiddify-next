import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/proxy/active/active_proxy_sidebar_card.dart';
import 'package:hiddify/features/stats/model/stats_entity.dart';
import 'package:hiddify/features/stats/notifier/stats_notifier.dart';
import 'package:hiddify/utils/number_formatters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SideBarStatsOverview extends HookConsumerWidget {
  const SideBarStatsOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final stats =
        ref.watch(statsNotifierProvider).asData?.value ?? StatsEntity.empty();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ActiveProxySideBarCard(),
          const Gap(8),
          _StatCard(
            title: t.home.stats.traffic,
            firstStat: (
              label: "↑",
              data: stats.uplink.speed(),
              semanticLabel: t.home.stats.uplink,
            ),
            secondStat: (
              label: "↓",
              data: stats.downlink.speed(),
              semanticLabel: t.home.stats.downlink,
            ),
          ),
          const Gap(8),
          _StatCard(
            title: t.home.stats.trafficTotal,
            firstStat: (
              label: "↑",
              data: stats.uplinkTotal.size(),
              semanticLabel: t.home.stats.uplink,
            ),
            secondStat: (
              label: "↓",
              data: stats.downlinkTotal.size(),
              semanticLabel: t.home.stats.downlink,
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
  final ({String label, String data, String semanticLabel}) firstStat;
  final ({String label, String data, String semanticLabel}) secondStat;

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
                  semanticsLabel: firstStat.semanticLabel,
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
                  semanticsLabel: secondStat.semanticLabel,
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
