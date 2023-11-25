import 'package:hiddify/features/geo_asset/model/geo_asset_entity.dart';

/// default geoip asset bundled with the app
const defaultGeoip = GeoAssetEntity(
  id: "sing-box-geoip",
  name: "geoip.db",
  type: GeoAssetType.geoip,
  active: true,
  providerName: "SagerNet/sing-geoip",
);

/// default geosite asset bundled with the app
const defaultGeosite = GeoAssetEntity(
  id: "sing-box-geosite",
  name: "geosite.db",
  type: GeoAssetType.geosite,
  active: true,
  providerName: "SagerNet/sing-geosite",
);

const defaultGeoAssets = [defaultGeoip, defaultGeosite];

const recommendedGeoAssets = [
  ...defaultGeoAssets,
  GeoAssetEntity(
    id: "chocolate4U-geoip",
    name: "geoip.db",
    type: GeoAssetType.geoip,
    active: false,
    providerName: "Chocolate4U/Iran-sing-box-rules",
  ),
  GeoAssetEntity(
    id: "chocolate4U-geosite",
    name: "geosite.db",
    type: GeoAssetType.geosite,
    active: false,
    providerName: "Chocolate4U/Iran-sing-box-rules",
  ),
];
