import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/features/logs/notifier/logs_state.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logs_notifier.g.dart';

// TODO: rewrite
@Riverpod(keepAlive: true)
class LogsNotifier extends _$LogsNotifier with AppLogger {
  static const maxLength = 1000;

  @override
  Stream<LogsState> build() {
    state = const AsyncData(LogsState());
    return ref.read(coreFacadeProvider).watchLogs().asyncMap(
      (event) async {
        _logs = [
          event.getOrElse((l) => throw l),
          ..._logs.takeFirst(maxLength - 1),
        ];
        return switch (state) {
          // ignore: unused_result
          AsyncData(:final value) => value.copyWith(logs: await _computeLogs()),
          _ => LogsState(logs: await _computeLogs()),
        };
      },
    );
  }

  var _logs = <String>[];
  final _debouncer = CallbackDebouncer(const Duration(milliseconds: 200));
  LogLevel? _levelFilter;
  String _filter = "";

  Future<List<String>> _computeLogs() async {
    if (_levelFilter == null && _filter.isEmpty) return _logs;
    return _logs.where((e) {
      return _filter.isEmpty || e.contains(_filter);
    }).toList();
  }

  void clear() {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(logs: [])).copyWithPrevious(state);
    }
  }

  void filterMessage(String? filter) {
    _filter = filter ?? '';
    _debouncer(
      () async {
        if (state case AsyncData(:final value)) {
          state = AsyncData(
            value.copyWith(
              filter: _filter,
              logs: await _computeLogs(),
            ),
          ).copyWithPrevious(state);
        }
      },
    );
  }

  Future<void> filterLevel(LogLevel? level) async {
    _levelFilter = level;
    if (state case AsyncData(:final value)) {
      state = AsyncData(
        value.copyWith(
          levelFilter: _levelFilter,
          logs: await _computeLogs(),
        ),
      ).copyWithPrevious(state);
    }
  }
}
