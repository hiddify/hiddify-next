import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/shimmer_skeleton.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/proxy/active/ip_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveProxySideBarCard extends HookConsumerWidget {
  const ActiveProxySideBarCard({super.key});

  Widget buildProp(Widget icon, Widget child) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        icon,
        const Gap(4),
        Flexible(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = ref.watch(translationsProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final ipInfo = ref.watch(ipInfoNotifierProvider);

    Widget propText(String txt) {
      return Text(
        txt,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      );
    }

    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(size: 14),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.home.stats.connection),
              const Gap(4),
              switch (activeProxy) {
                AsyncData(value: final proxy) => buildProp(
                    const Icon(FluentIcons.arrow_routing_20_regular),
                    propText(
                      proxy.selectedName.isNotNullOrBlank
                          ? proxy.selectedName!
                          : proxy.name,
                    ),
                  ),
                _ => buildProp(
                    const Icon(FluentIcons.arrow_routing_20_regular),
                    propText("..."),
                  ),
              },
              const Gap(4),
              switch (ipInfo) {
                AsyncData(value: final info) => buildProp(
                    IPCountryFlag(
                      countryCode: info.countryCode,
                      size: 16,
                    ),
                    IPText(
                      ip: info.ip,
                      onLongPress: () async {
                        ref.read(ipInfoNotifierProvider.notifier).refresh();
                      },
                      constrained: true,
                    ),
                  ),
                AsyncLoading() => buildProp(
                    const Icon(FluentIcons.question_circle_20_regular),
                    const ShimmerSkeleton(widthFactor: .85, height: 14),
                  ),
                _ => buildProp(
                    const Icon(FluentIcons.error_circle_20_regular),
                    propText(t.general.unknown),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
