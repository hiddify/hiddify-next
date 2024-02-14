import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/directories.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/connection/data/connection_platform_source.dart';
import 'package:hiddify/features/connection/model/connection_failure.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/geo_asset/data/geo_asset_path_resolver.dart';
import 'package:hiddify/features/profile/data/profile_path_resolver.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_status.dart';
import 'package:hiddify/singbox/service/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:meta/meta.dart';

abstract interface class ConnectionRepository {
  TaskEither<ConnectionFailure, Unit> setup();
  Stream<ConnectionStatus> watchConnectionStatus();
  TaskEither<ConnectionFailure, Unit> connect(
    String fileName,
    String profileName,
    bool disableMemoryLimit,
  );
  TaskEither<ConnectionFailure, Unit> disconnect();
  TaskEither<ConnectionFailure, Unit> reconnect(
    String fileName,
    String profileName,
    bool disableMemoryLimit,
  );
}

class ConnectionRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements ConnectionRepository {
  ConnectionRepositoryImpl({
    required this.directories,
    required this.singbox,
    required this.platformSource,
    required this.singBoxConfigOptionRepository,
    required this.profilePathResolver,
    required this.geoAssetPathResolver,
  });

  final Directories directories;
  final SingboxService singbox;
  final ConnectionPlatformSource platformSource;
  final SingBoxConfigOptionRepository singBoxConfigOptionRepository;
  final ProfilePathResolver profilePathResolver;
  final GeoAssetPathResolver geoAssetPathResolver;

  bool _initialized = false;

  @override
  Stream<ConnectionStatus> watchConnectionStatus() {
    return singbox.watchStatus().map(
          (event) => switch (event) {
            SingboxStopped(:final alert?, :final message) => Disconnected(
                switch (alert) {
                  SingboxAlert.emptyConfiguration =>
                    ConnectionFailure.invalidConfig(message),
                  SingboxAlert.requestNotificationPermission =>
                    ConnectionFailure.missingNotificationPermission(message),
                  SingboxAlert.requestVPNPermission =>
                    ConnectionFailure.missingVpnPermission(message),
                  SingboxAlert.startCommandServer ||
                  SingboxAlert.createService ||
                  SingboxAlert.startService =>
                    ConnectionFailure.unexpected(message),
                },
              ),
            SingboxStopped() => const Disconnected(),
            SingboxStarting() => const Connecting(),
            SingboxStarted() => const Connected(),
            SingboxStopping() => const Disconnecting(),
          },
        );
  }

  @visibleForTesting
  TaskEither<ConnectionFailure, SingboxConfigOption> getConfigOption() {
    return TaskEither<ConnectionFailure, SingboxConfigOption>.Do(
      ($) async {
        final options = await $(
          singBoxConfigOptionRepository
              .getFullSingboxConfigOption()
              .mapLeft((l) => const InvalidConfigOption()),
        );

        return $(
          TaskEither(
            () async {
              final geoip = geoAssetPathResolver.resolvePath(options.geoipPath);
              final geosite =
                  geoAssetPathResolver.resolvePath(options.geositePath);
              if (!await File(geoip).exists() ||
                  !await File(geosite).exists()) {
                return left(const ConnectionFailure.missingGeoAssets());
              }
              return right(options);
            },
          ),
        );
      },
    ).handleExceptions(UnexpectedConnectionFailure.new);
  }

  @visibleForTesting
  TaskEither<ConnectionFailure, Unit> applyConfigOption(
    SingboxConfigOption options,
  ) {
    return exceptionHandler(
      () {
        return singbox
            .changeOptions(options)
            .mapLeft(InvalidConfigOption.new)
            .run();
      },
      UnexpectedConnectionFailure.new,
    );
  }

  @override
  TaskEither<ConnectionFailure, Unit> setup() {
    if (_initialized) return TaskEither.of(unit);
    return exceptionHandler(
      () {
        loggy.debug("setting up singbox");
        return singbox
            .setup(
              directories,
              false,
            )
            .map((r) {
              _initialized = true;
              return r;
            })
            .mapLeft(UnexpectedConnectionFailure.new)
            .run();
      },
      UnexpectedConnectionFailure.new,
    );
  }

  @override
  TaskEither<ConnectionFailure, Unit> connect(
    String fileName,
    String profileName,
    bool disableMemoryLimit,
  ) {
    return TaskEither<ConnectionFailure, Unit>.Do(
      ($) async {
        final options = await $(getConfigOption());
        loggy.info(
          "config options: ${options.format()}\nMemory Limit: ${!disableMemoryLimit}",
        );

        await $(
          TaskEither(() async {
            if (options.enableTun) {
              final hasPrivilege = await platformSource.checkPrivilege();
              if (!hasPrivilege) {
                loggy.warning("missing privileges for tun mode");
                return left(const MissingPrivilege());
              }
            }
            return right(unit);
          }),
        );
        await $(setup());
        await $(applyConfigOption(options));
        return await $(
          singbox
              .start(
                profilePathResolver.file(fileName).path,
                profileName,
                disableMemoryLimit,
              )
              .mapLeft(UnexpectedConnectionFailure.new),
        );
      },
    ).handleExceptions(UnexpectedConnectionFailure.new);
  }

  @override
  TaskEither<ConnectionFailure, Unit> disconnect() {
    return TaskEither<ConnectionFailure, Unit>.Do(
      ($) async {
        final options = await $(getConfigOption());

        await $(
          TaskEither(() async {
            if (options.enableTun) {
              final hasPrivilege = await platformSource.checkPrivilege();
              if (!hasPrivilege) {
                loggy.warning("missing privileges for tun mode");
                return left(const MissingPrivilege());
              }
            }
            return right(unit);
          }),
        );
        return await $(
          singbox.stop().mapLeft(UnexpectedConnectionFailure.new),
        );
      },
    ).handleExceptions(UnexpectedConnectionFailure.new);
  }

  @override
  TaskEither<ConnectionFailure, Unit> reconnect(
    String fileName,
    String profileName,
    bool disableMemoryLimit,
  ) {
    return exceptionHandler(
      () async {
        return getConfigOption()
            .flatMap((options) => applyConfigOption(options))
            .andThen(
              () => singbox
                  .restart(
                    profilePathResolver.file(fileName).path,
                    profileName,
                    disableMemoryLimit,
                  )
                  .mapLeft(UnexpectedConnectionFailure.new),
            )
            .run();
      },
      UnexpectedConnectionFailure.new,
    );
  }
}
