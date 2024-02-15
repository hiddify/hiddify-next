import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/utils/platform_utils.dart';

part 'singbox_config_enum.mapper.dart';

@MappableEnum()
enum ServiceMode {
  @MappableValue("proxy")
  proxy,

  @MappableValue("system-proxy")
  systemProxy,

  @MappableValue("vpn")
  tun,

  @MappableValue("vpn-service")
  tunService;

  static ServiceMode get defaultMode =>
      PlatformUtils.isDesktop ? systemProxy : tun;

  /// supported service mode based on platform, use this instead of [values] in UI
  static List<ServiceMode> get choices {
    if (Platform.isWindows || Platform.isLinux) {
      return values;
    } else if (Platform.isMacOS) {
      return [proxy, systemProxy, tun];
    }
    // mobile
    return [proxy, tun];
  }

  String present(TranslationsEn t) => switch (this) {
        proxy => t.settings.config.serviceModes.proxy,
        systemProxy => t.settings.config.serviceModes.systemProxy,
        tun =>
          "${t.settings.config.serviceModes.tun}${PlatformUtils.isDesktop ? " (${t.settings.experimental})" : ""}",
        tunService =>
          "${t.settings.config.serviceModes.tunService}${PlatformUtils.isDesktop ? " (${t.settings.experimental})" : ""}",
      };
}

@MappableEnum()
enum IPv6Mode {
  @MappableValue("ipv4_only")
  disable,

  @MappableValue("prefer_ipv4")
  enable,

  @MappableValue("prefer_ipv6")
  prefer,

  @MappableValue("ipv6_only")
  only;

  String present(TranslationsEn t) => switch (this) {
        disable => t.settings.config.ipv6Modes.disable,
        enable => t.settings.config.ipv6Modes.enable,
        prefer => t.settings.config.ipv6Modes.prefer,
        only => t.settings.config.ipv6Modes.only,
      };
}

@MappableEnum()
enum DomainStrategy {
  @MappableValue("")
  auto(""),

  @MappableValue("prefer_ipv6")
  preferIpv6("prefer_ipv6"),

  @MappableValue("prefer_ipv4")
  preferIpv4("prefer_ipv4"),

  @MappableValue("ipv4_only")
  ipv4Only("ipv4_only"),

  @MappableValue("ipv6_only")
  ipv6Only("ipv6_only");

  const DomainStrategy(this.key);

  final String key;

  String get displayName => switch (this) {
        auto => "auto",
        _ => key,
      };
}

@MappableEnum()
enum TunImplementation {
  mixed,
  system,
  gVisor;
}

@MappableEnum()
enum MuxProtocol {
  h2mux,
  smux,
  yamux;
}

@MappableEnum()
enum WarpDetourMode {
  outbound,
  inbound;

  String present(TranslationsEn t) => switch (this) {
        outbound => t.settings.config.warpDetourModes.outbound,
        inbound => t.settings.config.warpDetourModes.inbound,
      };
}
