import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'warp_account.freezed.dart';
part 'warp_account.g.dart';

@freezed
class WarpAccount with _$WarpAccount {
  const factory WarpAccount({
    required String licenseKey,
    required String accountId,
    required String accessToken,
  }) = _WarpAccount;

  factory WarpAccount.fromJson(Map<String, dynamic> json) =>
      _$WarpAccountFromJson(json);
}
