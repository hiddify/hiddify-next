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
    return ListTile(
      title: Text(
        proxy.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(proxy.type.label),
      trailing: delay != null ? Text(delay.toString()) : null,
      selected: selected,
      onTap: onSelect,
    );
  }
}
