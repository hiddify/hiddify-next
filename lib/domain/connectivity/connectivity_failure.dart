import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/locale/locale.dart';
import 'package:hiddify/domain/failures.dart';

part 'connectivity_failure.freezed.dart';

// TODO: rewrite
@freezed
sealed class ConnectivityFailure with _$ConnectivityFailure, Failure {
  const ConnectivityFailure._();

  const factory ConnectivityFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = ConnectivityUnexpectedFailure;

  @override
  String present(TranslationsEn t) {
    return t.failure.connectivity.unexpected;
  }
}
