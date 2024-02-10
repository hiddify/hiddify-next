import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/animated_visibility.dart';
import 'package:hiddify/core/widget/shimmer_skeleton.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/proxy/active/ip_widget.dart';
import 'package:hiddify/features/stats/notifier/stats_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveProxyFooter extends HookConsumerWidget {
  const ActiveProxyFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncState = ref.watch(activeProxyNotifierProvider);
    final stats = ref.watch(statsNotifierProvider).value;

    return AnimatedVisibility(
      axis: Axis.vertical,
      visible: asyncState is AsyncData,
      child: switch (asyncState) {
        AsyncData(value: final info) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoProp(
                        icon: FluentIcons.arrow_routing_20_regular,
                        text: info.proxy.selectedName.isNotNullOrBlank
                            ? info.proxy.selectedName!
                            : info.proxy.name,
                      ),
                      const Gap(8),
                      switch (info.ipInfo) {
                        AsyncData(value: final ipInfo?) => Row(
                            children: [
                              IPCountryFlag(countryCode: ipInfo.countryCode),
                              const Gap(8),
                              IPText(
                                ip: ipInfo.ip,
                                onLongPress: () async {
                                  ref
                                      .read(
                                        activeProxyNotifierProvider.notifier,
                                      )
                                      .refreshIpInfo();
                                },
                              ),
                            ],
                          ),
                        AsyncError() => _InfoProp(
                            icon: FluentIcons.error_circle_20_regular,
                            text: t.general.unknown,
                          ),
                        _ => const Row(
                            children: [
                              Icon(FluentIcons.question_circle_20_regular),
                              Gap(8),
                              Flexible(
                                child: ShimmerSkeleton(
                                  height: 16,
                                  widthFactor: 1,
                                ),
                              ),
                            ],
                          ),
                      },
                    ],
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.values[
                      (Directionality.of(context).index + 1) %
                          TextDirection.values.length],
                  child: Flexible(
                    child: Column(
                      children: [
                        _InfoProp(
                          icon: FluentIcons
                              .arrow_bidirectional_up_down_20_regular,
                          text: (stats?.downlinkTotal ?? 0).size(),
                        ),
                        const Gap(8),
                        _InfoProp(
                          icon: FluentIcons.arrow_download_20_regular,
                          text: (stats?.downlink ?? 0).speed(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _InfoProp extends StatelessWidget {
  const _InfoProp({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const Gap(8),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
