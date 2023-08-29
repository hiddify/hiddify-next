import 'package:flutter/material.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxyTile extends HookConsumerWidget {
  const ProxyTile(
    this.proxy, {
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final OutboundGroupItem proxy;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        proxy.tag,
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
      subtitle: Text(
        proxy.type.label,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          proxy.urlTestDelay != 0 ? Text(proxy.urlTestDelay.toString()) : null,
      selected: selected,
      onTap: onSelect,
      horizontalTitleGap: 4,
    );
  }
}
