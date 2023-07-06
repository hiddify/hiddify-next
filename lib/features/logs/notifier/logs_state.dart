import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/clash/clash.dart';

part 'logs_state.freezed.dart';

@freezed
class LogsState with _$LogsState {
  const LogsState._();

  const factory LogsState({
    @Default([]) List<ClashLog> logs,
    @Default("") String filter,
    LogLevel? levelFilter,
  }) = _LogsState;
}
