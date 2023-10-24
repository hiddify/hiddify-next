import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/singbox/singbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logs_state.freezed.dart';

@freezed
class LogsState with _$LogsState {
  const LogsState._();

  const factory LogsState({
    @Default(AsyncLoading()) AsyncValue<List<BoxLog>> logs,
    @Default(false) bool paused,
    @Default("") String filter,
    LogLevel? levelFilter,
  }) = _LogsState;
}
