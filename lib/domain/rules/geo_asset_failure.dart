import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/failures.dart';

part 'geo_asset_failure.freezed.dart';

@freezed
sealed class GeoAssetFailure with _$GeoAssetFailure, Failure {
    const GeoAssetFailure._();

  const factory GeoAssetFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = GeoAssetUnexpectedFailure;

  @With<ExpectedFailure>()
  const factory GeoAssetFailure.noUpdateAvailable() = GeoAssetNoUpdateAvailable;

  const factory GeoAssetFailure.activeAssetNotFound() =
      GeoAssetActiveAssetNotFound;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      GeoAssetUnexpectedFailure() => (
          type: t.failure.geoAssets.unexpected,
          message: null,
        ),
      GeoAssetNoUpdateAvailable() => (
          type: t.failure.geoAssets.notUpdate,
          message: null
        ),
      GeoAssetActiveAssetNotFound() => (
          type: t.failure.geoAssets.activeNotFound,
          message: null,
        ),
    };
  }
}
