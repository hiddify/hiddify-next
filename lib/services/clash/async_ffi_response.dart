import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_ffi_response.freezed.dart';
part 'async_ffi_response.g.dart';

@freezed
class AsyncFfiResponse with _$AsyncFfiResponse {
  const AsyncFfiResponse._();

  const factory AsyncFfiResponse({
    @JsonKey(name: 'success') required bool success,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'data') String? data,
  }) = _AsyncFfiResponse;

  factory AsyncFfiResponse.fromJson(Map<String, dynamic> json) =>
      _$AsyncFfiResponseFromJson(json);
}
