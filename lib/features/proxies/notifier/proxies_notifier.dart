import 'dart:async';

import 'package:combine/combine.dart';
import 'package:dartx/dartx.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/utils/pref_notifier.dart';
import 'package:hiddify/utils/riverpod_utils.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'proxies_notifier.g.dart';

enum ProxiesSort {
  unsorted,
  name,
  delay;

  String present(TranslationsEn t) => switch (this) {
        ProxiesSort.unsorted => t.proxies.sortOptions.unsorted,
        ProxiesSort.name => t.proxies.sortOptions.name,
        ProxiesSort.delay => t.proxies.sortOptions.delay,
      };
}

@Riverpod(keepAlive: true)
class ProxiesSortNotifier extends _$ProxiesSortNotifier {
  late final _pref = Pref(
    ref.watch(sharedPreferencesProvider),
    "proxies_sort_mode",
    ProxiesSort.unsorted,
    mapFrom: ProxiesSort.values.byName,
    mapTo: (value) => value.name,
  );

  @override
  ProxiesSort build() => _pref.getValue();

  Future<void> update(ProxiesSort value) {
    state = value;
    return _pref.update(value);
  }
}

@riverpod
class ProxiesNotifier extends _$ProxiesNotifier with AppLogger {
  @override
  Stream<List<OutboundGroup>> build() async* {
    ref.disposeDelay(const Duration(seconds: 15));
    final serviceRunning = await ref.watch(serviceRunningProvider.future);
    if (!serviceRunning) {
      throw const CoreServiceNotRunning();
    }
    final sortBy = ref.watch(proxiesSortNotifierProvider);
    yield* ref
        .watch(coreFacadeProvider)
        .watchOutbounds()
        .throttleTime(
          const Duration(milliseconds: 100),
          leading: false,
          trailing: true,
        )
        .map(
          (event) => event.getOrElse(
            (err) {
              loggy.warning("error receiving proxies", err);
              throw err;
            },
          ),
        )
        .asyncMap((proxies) async => _sortOutbounds(proxies, sortBy));
  }

  Future<List<OutboundGroup>> _sortOutbounds(
    List<OutboundGroup> outbounds,
    ProxiesSort sortBy,
  ) async {
    return CombineWorker().execute(
      () {
        final groupWithSelected = {
          for (final o in outbounds) o.tag: o.selected,
        };
        final sortedOutbounds = <OutboundGroup>[];
        for (final group in outbounds) {
          final sortedItems = switch (sortBy) {
            ProxiesSort.name => group.items.sortedBy((e) => e.tag),
            ProxiesSort.delay => group.items.sortedWith((a, b) {
                final ai = a.urlTestDelay;
                final bi = b.urlTestDelay;
                if (ai == 0 && bi == 0) return -1;
                if (ai == 0 && bi > 0) return 1;
                if (ai > 0 && bi == 0) return -1;
                if (ai == bi && a.type.isGroup) return -1;
                return ai.compareTo(bi);
              }),
            ProxiesSort.unsorted => group.items,
          };
          final items = <OutboundGroupItem>[];
          for (final item in sortedItems) {
            if (groupWithSelected.keys.contains(item.tag)) {
              items
                  .add(item.copyWith(selectedTag: groupWithSelected[item.tag]));
            } else {
              items.add(item);
            }
          }
          sortedOutbounds.add(group.copyWith(items: items));
        }
        return sortedOutbounds;
      },
    );
  }

  Future<void> changeProxy(String groupTag, String outboundTag) async {
    loggy.debug(
      "changing proxy, group: [$groupTag] - outbound: [$outboundTag]",
    );
    if (state case AsyncData(value: final outbounds)) {
      await ref
          .read(coreFacadeProvider)
          .selectOutbound(groupTag, outboundTag)
          .getOrElse((err) {
        loggy.warning("error selecting outbound", err);
        throw err;
      }).run();
      state = AsyncData(
        [
          ...outbounds.map(
            (e) => e.tag == groupTag ? e.copyWith(selected: outboundTag) : e,
          ),
        ],
      ).copyWithPrevious(state);
    }
  }

  Future<void> urlTest(String groupTag) async {
    loggy.debug("testing group: [$groupTag]");
    if (state case AsyncData()) {
      await ref.read(coreFacadeProvider).urlTest(groupTag).getOrElse((err) {
        loggy.error("error testing group", err);
        throw err;
      }).run();
    }
  }
}
