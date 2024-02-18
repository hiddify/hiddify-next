import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/config_option/model/config_option_entity.dart';
import 'package:hiddify/features/config_option/model/config_option_failure.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_path_resolver.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';
import 'package:hiddify/singbox/service/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ConfigOptionRepository {
  Either<ConfigOptionFailure, ConfigOptionEntity> getConfigOption();
  TaskEither<ConfigOptionFailure, Unit> updateConfigOption(
    ConfigOptionPatch patch,
  );
  TaskEither<ConfigOptionFailure, Unit> resetConfigOption();
  TaskEither<ConfigOptionFailure, Unit> generateWarpConfig();
}

abstract interface class SingBoxConfigOptionRepository {
  TaskEither<ConfigOptionFailure, SingboxConfigOption>
      getFullSingboxConfigOption();
}

class ConfigOptionRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements ConfigOptionRepository {
  ConfigOptionRepositoryImpl({
    required this.preferences,
    required this.singbox,
  });

  final SharedPreferences preferences;
  final SingboxService singbox;

  @override
  Either<ConfigOptionFailure, ConfigOptionEntity> getConfigOption() {
    try {
      final map = ConfigOptionEntity.initial().toJson();
      for (final key in map.keys) {
        final persisted = preferences.get(key);
        if (persisted != null) {
          final defaultValue = map[key];
          if (defaultValue != null &&
              persisted.runtimeType != defaultValue.runtimeType) {
            loggy.warning(
              "error getting preference[$key], expected type: [${defaultValue.runtimeType}] - received value: [$persisted](${persisted.runtimeType})",
            );
            continue;
          }
          map[key] = persisted;
        }
      }
      final options = ConfigOptionEntity.fromJson(map);
      return right(options);
    } catch (error, stackTrace) {
      return left(ConfigOptionUnexpectedFailure(error, stackTrace));
    }
  }

  @override
  TaskEither<ConfigOptionFailure, Unit> updateConfigOption(
    ConfigOptionPatch patch,
  ) {
    return exceptionHandler(
      () async {
        final map = patch.toJson();
        await updateByJson(map);
        return right(unit);
      },
      ConfigOptionUnexpectedFailure.new,
    );
  }

  @override
  TaskEither<ConfigOptionFailure, Unit> resetConfigOption() {
    return exceptionHandler(
      () async {
        final map = ConfigOptionEntity.initial().toJson();
        await updateByJson(map);
        return right(unit);
      },
      ConfigOptionUnexpectedFailure.new,
    );
  }

  @visibleForTesting
  Future<void> updateByJson(
    Map<String, dynamic> options,
  ) async {
    final map = ConfigOptionEntity.initial().toJson();
    for (final key in map.keys) {
      final value = options[key];
      if (value != null) {
        loggy.debug("updating [$key] to [$value]");

        switch (value) {
          case bool _:
            await preferences.setBool(key, value);
          case String _:
            await preferences.setString(key, value);
          case int _:
            await preferences.setInt(key, value);
          case double _:
            await preferences.setDouble(key, value);
          default:
            loggy.warning("unexpected type");
        }
      }
    }
  }

  @override
  TaskEither<ConfigOptionFailure, Unit> generateWarpConfig() {
    return exceptionHandler(
      () async {
        final options = getConfigOption().getOrElse((l) => throw l);
        return await singbox
            .generateWarpConfig(
              licenseKey: options.warpLicenseKey,
              previousAccountId: options.warpAccountId,
              previousAccessToken: options.warpAccessToken,
            )
            .mapLeft((l) => ConfigOptionFailure.unexpected(l))
            .flatMap(
              (warp) => updateConfigOption(
                ConfigOptionPatch(
                  warpAccountId: warp.accountId,
                  warpAccessToken: warp.accessToken,
                ),
              ),
            )
            .run();
      },
      (error, stackTrace) {
        loggy.error(error);
        return ConfigOptionUnexpectedFailure(error, stackTrace);
      },
    );
  }
}

class SingBoxConfigOptionRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements SingBoxConfigOptionRepository {
  SingBoxConfigOptionRepositoryImpl({
    required this.preferences,
    required this.optionsRepository,
    required this.geoAssetRepository,
    required this.geoAssetPathResolver,
  });

  final SharedPreferences preferences;
  final ConfigOptionRepository optionsRepository;
  final GeoAssetRepository geoAssetRepository;
  final GeoAssetPathResolver geoAssetPathResolver;

  @override
  TaskEither<ConfigOptionFailure, SingboxConfigOption>
      getFullSingboxConfigOption() {
    return exceptionHandler(
      () async {
        final region =
            Region.values.byName(preferences.getString("region") ?? "other");
        final rules = switch (region) {
          Region.ir => [
              const SingboxRule(
                domains: "domain:.ir,geosite:ir",
                ip: "geoip:ir",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.cn => [
              const SingboxRule(
                domains: "domain:.cn,geosite:cn",
                ip: "geoip:cn",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.ru => [
              const SingboxRule(
                domains: "domain:.ru",
                ip: "geoip:ru",
                outbound: RuleOutbound.bypass,
              ),
            ],
          Region.af => [
              const SingboxRule(
                domains: "domain:.af,geosite:af",
                ip: "geoip:af",
                outbound: RuleOutbound.bypass,
              ),
            ],
          _ => <SingboxRule>[],
        };

        final geoAssets = await geoAssetRepository
            .getActivePair()
            .getOrElse((l) => throw l)
            .run();

        final persisted =
            optionsRepository.getConfigOption().getOrElse((l) => throw l);
        final singboxConfigOption = persisted.toSingbox(
          geoipPath: geoAssetPathResolver.relativePath(
            geoAssets.geoip.providerName,
            geoAssets.geoip.fileName,
          ),
          geositePath: geoAssetPathResolver.relativePath(
            geoAssets.geosite.providerName,
            geoAssets.geosite.fileName,
          ),
          rules: rules,
        );
        return right(singboxConfigOption);
      },
      ConfigOptionUnexpectedFailure.new,
    );
  }
}
