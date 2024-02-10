import 'package:circle_flags/circle_flags.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/animated_visibility.dart';
import 'package:hiddify/core/widget/skeleton_widget.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
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
                        icon: FluentIcons.arrow_routing_24_regular,
                        text: info.proxy.selectedName.isNotNullOrBlank
                            ? info.proxy.selectedName!
                            : info.proxy.name,
                      ),
                      const Gap(8),
                      switch (info.ipInfo) {
                        AsyncData(value: final ip?) => _InfoProp.flag(
                            countryCode: ip.countryCode,
                            text: ip.ip,
                          ),
                        AsyncError() => _InfoProp(
                            icon: FluentIcons.error_circle_20_regular,
                            text: t.general.unknown,
                          ),
                        _ => _InfoProp.loading(
                            icon: FluentIcons.question_circle_24_regular,
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
                              .arrow_bidirectional_up_down_24_regular,
                          text: (stats?.downlinkTotal ?? 0).size(),
                        ),
                        const Gap(8),
                        _InfoProp(
                          icon: FluentIcons.arrow_download_24_regular,
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
  _InfoProp({
    required IconData icon,
    required String text,
  })  : icon = Icon(icon),
        child = IPWidget(text),
        isLoading = false;

  _InfoProp.flag({
    required String countryCode,
    required String text,
  })  : icon = Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2),
          child: CircleFlag(countryCode),
        ),
        child = IPWidget(text),
        isLoading = false;

  _InfoProp.loading({
    required IconData icon,
  })  : icon = Icon(icon),
        child = const SizedBox(),
        isLoading = true;

  final Widget icon;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const Gap(8),
        if (isLoading)
          Flexible(
            child: const Skeleton(height: 16, widthFactor: 1)
                .animate(
                  onPlay: (controller) => controller.loop(),
                )
                .shimmer(
                  duration: 1000.ms,
                  angle: 45,
                  color: Theme.of(context).colorScheme.secondary,
                ),
          )
        else
          Flexible(child: child),
      ],
    );
  }
}

class IPWidget extends StatefulWidget {
  final String text1;
  final String text2;

  IPWidget(String text)
      : text1 = _replaceMiddlePart(text),
        text2 = text,
        super(key: UniqueKey());
  static String _replaceMiddlePart(String ip) {
    RegExp regex = RegExp(
      r'^([\da-f]+([:.]))([\da-f:.]*)([:.][\da-f]+)$',
      caseSensitive: false,
    );

    return ip.replaceAllMapped(regex, (match) {
      return '${match[1]} ░ ${match[2]} ░ ${match[4]}';
    });
  }

  @override
  _IPWidgetState createState() => _IPWidgetState();
}

class _IPWidgetState extends State<IPWidget> {
  bool isText1Visible = true;

  void toggleVisibility() {
    setState(() {
      isText1Visible = !isText1Visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleVisibility,
      child: Text(
        isText1Visible ? widget.text1 : widget.text2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
