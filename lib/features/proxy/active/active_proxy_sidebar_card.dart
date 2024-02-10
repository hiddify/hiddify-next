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
    final asyncState = ref.watch(activeProxyNotifierProvider);

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
              switch (asyncState) {
                AsyncData(:final value) => buildProp(
                    const Icon(FluentIcons.arrow_routing_20_regular),
                    propText(
                      value.proxy.selectedName.isNotNullOrBlank
                          ? value.proxy.selectedName!
                          : value.proxy.name,
                    ),
                  ),
                _ => buildProp(
                    const Icon(FluentIcons.arrow_routing_20_regular),
                    propText("..."),
                  ),
              },
              const Gap(4),
              () {
                if (asyncState case AsyncData(:final value)) {
                  switch (value.ipInfo) {
                    case AsyncData(value: final ipInfo?):
                      return buildProp(
                        IPCountryFlag(
                            countryCode: ipInfo.countryCode, size: 16),
                        IPText(
                          ip: ipInfo.ip,
                          onLongPress: () async {
                            ref
                                .read(
                                  activeProxyNotifierProvider.notifier,
                                )
                                .refreshIpInfo();
                          },
                          constrained: true,
                        ),
                      );
                    case AsyncError():
                      return buildProp(
                        const Icon(FluentIcons.error_circle_20_regular),
                        propText(t.general.unknown),
                      );
                    case AsyncLoading():
                      return buildProp(
                        const Icon(FluentIcons.question_circle_20_regular),
                        const ShimmerSkeleton(widthFactor: .85, height: 14),
                      );
                  }
                }

                return buildProp(
                  const Icon(FluentIcons.question_circle_20_regular),
                  propText(t.general.unknown),
                );
              }(),
            ],
          ),
        ),
      ),
    );
  }
}
