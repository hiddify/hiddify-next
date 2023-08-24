import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:hiddify/core/prefs/misc_prefs.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/features/common/active_profile/active_profile_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'proxies_delay_notifier.g.dart';

// TODO: rewrite
@Riverpod(keepAlive: true)
class ProxiesDelayNotifier extends _$ProxiesDelayNotifier with AppLogger {
  @override
  Map<String, int> build() {
    ref.onDispose(
      () {
        loggy.debug("disposing");
        _currentTest?.cancel();
      },
    );

    ref.listen(
      activeProfileProvider.selectAsync((value) => value?.id),
      (prev, next) async {
        if (await prev != await next) ref.invalidateSelf();
      },
    );

    return {};
  }

  ClashFacade get _clash => ref.read(coreFacadeProvider);
  StreamSubscription? _currentTest;

  Future<void> testDelay(Iterable<String> proxies) async {
    final testUrl = ref.read(connectionTestUrlProvider);
    final concurrent = ref.read(concurrentTestCountProvider);

    loggy.info(
      'testing delay for [${proxies.length}] proxies with [$testUrl], [$concurrent] at a time',
    );

    // cancel possible running test
    await _currentTest?.cancel();

    // reset previous
    state = state.filterNot((entry) => proxies.contains(entry.key));

    void setDelay(String name, int delay) {
      state = {
        ...state
          ..update(
            name,
            (_) => delay,
            ifAbsent: () => delay,
          ),
      };
    }

    _currentTest = Stream.fromIterable(proxies)
        .bufferCount(concurrent)
        .asyncMap(
          (chunk) => Future.wait(
            chunk.map(
              (e) async => setDelay(
                e,
                await _clash
                    .testDelay(e, testUrl: testUrl)
                    .getOrElse((l) => -1)
                    .run(),
              ),
            ),
          ),
        )
        .listen((event) {});
  }

  Future<void> cancelDelayTest() async => _currentTest?.cancel();
}
