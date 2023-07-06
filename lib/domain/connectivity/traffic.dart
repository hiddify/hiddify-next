import 'package:freezed_annotation/freezed_annotation.dart';

part 'traffic.freezed.dart';

@freezed
class Traffic with _$Traffic {
  const Traffic._();

  const factory Traffic({
    required int upload,
    required int download,
  }) = _Traffic;
}
