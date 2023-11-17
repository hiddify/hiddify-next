import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_asset.freezed.dart';
part 'geo_asset.g.dart';

enum GeoAssetType { geoip, geosite }

typedef GeoAssetWithFileSize = (GeoAsset geoAsset, int? size);

@freezed
class GeoAsset with _$GeoAsset {
  const GeoAsset._();

  const factory GeoAsset({
    required String id,
    required String name,
    required GeoAssetType type,
    required bool active,
    required String providerName,
    String? version,
    DateTime? lastCheck,
  }) = _GeoAsset;

  factory GeoAsset.fromJson(Map<String, dynamic> json) =>
      _$GeoAssetFromJson(json);

  String get fileName => name;

  String get repositoryUrl =>
      "https://api.github.com/repos/$providerName/releases/latest";
}

/// default geoip asset bundled with the app
const defaultGeoip = GeoAsset(
  id: "sing-box-geoip",
  name: "geoip.db",
  type: GeoAssetType.geoip,
  active: true,
  providerName: "SagerNet/sing-geoip",
);

/// default geosite asset bundled with the app
const defaultGeosite = GeoAsset(
  id: "sing-box-geosite",
  name: "geosite.db",
  type: GeoAssetType.geosite,
  active: true,
  providerName: "SagerNet/sing-geosite",
);

const defaultGeoAssets = [defaultGeoip, defaultGeosite];
