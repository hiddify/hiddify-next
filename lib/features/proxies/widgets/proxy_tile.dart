import 'package:flutter/material.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: rewrite
class ProxyTile extends HookConsumerWidget {
  const ProxyTile(
    this.proxy, {
    super.key,
    required this.selected,
    required this.onSelect,
    this.delay,
  });

  final ClashProxy proxy;
  final bool selected;
  final VoidCallback onSelect;
  final int? delay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        switch (proxy) {
          ClashProxyGroup(:final name) => name.toUpperCase(),
          ClashProxyItem(:final name) => name,
        },
        overflow: TextOverflow.ellipsis,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          width: 6,
          height: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: proxy.type.label),
            if (proxy.udp)
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.tertiaryContainer,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      " UDP ",
                      style: TextStyle(
                        fontSize: theme.textTheme.labelSmall?.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            if (proxy case ClashProxyGroup(:final now)) ...[
              TextSpan(text: " ($now)"),
            ],
          ],
        ),
      ),
      trailing: delay != null ? Text(delay.toString()) : null,
      selected: selected,
      onTap: onSelect,
      horizontalTitleGap: 4,
    );
  }
}
