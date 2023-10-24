import 'dart:async';

import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:hiddify/features/logs/notifier/logs_state.dart';
import 'package:hiddify/utils/riverpod_utils.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'logs_notifier.g.dart';

@riverpod
class LogsNotifier extends _$LogsNotifier with AppLogger {
  @override
  LogsState build() {
    ref.disposeDelay(const Duration(seconds: 20));
    state = const LogsState();
    ref.onDispose(
      () {
        loggy.debug("disposing");
        _listener?.cancel();
        _listener = null;
      },
    );
    ref.onCancel(
      () {
        if (_listener?.isPaused != true) {
          loggy.debug("pausing");
          _listener?.pause();
        }
      },
    );
    ref.onResume(
      () {
        if (!state.paused && (_listener?.isPaused ?? false)) {
          loggy.debug("resuming");
          _listener?.resume();
        }
      },
    );

    _addListeners();
    return const LogsState();
  }

  StreamSubscription? _listener;

  Future<void> _addListeners() async {
    loggy.debug("adding listeners");
    await _listener?.cancel();
    _listener = ref
        .read(coreFacadeProvider)
        .watchLogs()
        .throttle(
          (_) => Stream.value(_listener?.isPaused ?? false),
          leading: false,
          trailing: true,
        )
        .throttleTime(
          const Duration(milliseconds: 250),
          leading: false,
          trailing: true,
        )
        .asyncMap(
      (event) async {
        await event.fold(
          (f) {
            _logs = [];
            state = state.copyWith(logs: AsyncError(f, StackTrace.current));
          },
          (a) async {
            _logs = a.reversed;
            state = state.copyWith(logs: AsyncData(await _computeLogs()));
          },
        );
      },
    ).listen((event) {});
  }

  Iterable<String> _logs = [];
  final _debouncer = CallbackDebouncer(const Duration(milliseconds: 200));
  LogLevel? _levelFilter;
  String _filter = "";

  Future<List<BoxLog>> _computeLogs() async {
    final logs = _logs.map(BoxLog.parse);
    if (_levelFilter == null && _filter.isEmpty) return logs.toList();
    return logs.where((e) {
      return (_filter.isEmpty || e.message.contains(_filter)) &&
          (_levelFilter == null ||
              e.level == null ||
              e.level!.index >= _levelFilter!.index);
    }).toList();
  }

  void pause() {
    loggy.debug("pausing");
    _listener?.pause();
    state = state.copyWith(paused: true);
  }

  void resume() {
    loggy.debug("resuming");
    _listener?.resume();
    state = state.copyWith(paused: false);
  }

  Future<void> clear() async {
    loggy.debug("clearing");
    await ref.read(coreFacadeProvider).clearLogs().match(
      (l) {
        loggy.warning("error clearing logs", l);
      },
      (_) {
        _logs = [];
        state = state.copyWith(logs: const AsyncData([]));
      },
    ).run();
  }

  void filterMessage(String? filter) {
    _filter = filter ?? '';
    _debouncer(
      () async {
        if (state.logs case AsyncData()) {
          state = state.copyWith(
            filter: _filter,
            logs: AsyncData(await _computeLogs()),
          );
        }
      },
    );
  }

  Future<void> filterLevel(LogLevel? level) async {
    _levelFilter = level;
    if (state.logs case AsyncData()) {
      state = state.copyWith(
        levelFilter: _levelFilter,
        logs: AsyncData(await _computeLogs()),
      );
    }
  }
}
