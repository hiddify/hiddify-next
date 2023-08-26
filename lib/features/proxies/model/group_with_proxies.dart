import 'package:combine/combine.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash.dart';

part 'group_with_proxies.freezed.dart';

@freezed
class GroupWithProxies with _$GroupWithProxies {
  const GroupWithProxies._();

  const factory GroupWithProxies({
    required ClashProxyGroup group,
    required List<ClashProxy> proxies,
  }) = _GroupWithProxies;

  static Future<List<GroupWithProxies>> fromProxies(
    List<ClashProxy> proxies,
  ) async {
    final stopWatch = Stopwatch()..start();
    final res = await CombineWorker().execute(
      () {
        final result = <GroupWithProxies>[];
        for (final proxy in proxies) {
          if (proxy is ClashProxyGroup) {
            // if (mode != TunnelMode.global && proxy.name == "GLOBAL") continue;
            if (proxy.name == "GLOBAL") continue;
            final current = <ClashProxy>[];
            for (final name in proxy.all) {
              current.addAll(proxies.where((e) => e.name == name).toList());
            }
            result.add(GroupWithProxies(group: proxy, proxies: current));
          }
        }
        return result;
      },
    );
    debugPrint(
      "computed grouped proxies in [${stopWatch.elapsedMilliseconds}ms]",
    );
    return res;
  }
}
