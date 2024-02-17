import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/utils/platform_utils.dart';

@JsonEnum(valueField: 'key')
enum ServiceMode {
  proxy("proxy"),
  systemProxy("system-proxy"),
  tun("vpn"),
  tunService("vpn-service");

  const ServiceMode(this.key);

  final String key;

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

@JsonEnum(valueField: 'key')
enum IPv6Mode {
  disable("ipv4_only"),
  enable("prefer_ipv4"),
  prefer("prefer_ipv6"),
  only("ipv6_only");

  const IPv6Mode(this.key);

  final String key;

  String present(TranslationsEn t) => switch (this) {
        disable => t.settings.config.ipv6Modes.disable,
        enable => t.settings.config.ipv6Modes.enable,
        prefer => t.settings.config.ipv6Modes.prefer,
        only => t.settings.config.ipv6Modes.only,
      };
}

@JsonEnum(valueField: 'key')
enum DomainStrategy {
  auto(""),
  preferIpv6("prefer_ipv6"),
  preferIpv4("prefer_ipv4"),
  ipv4Only("ipv4_only"),
  ipv6Only("ipv6_only");

  const DomainStrategy(this.key);

  final String key;

  String get displayName => switch (this) {
        auto => "auto",
        _ => key,
      };
}

enum TunImplementation {
  mixed,
  system,
  gVisor;
}

enum MuxProtocol {
  h2mux,
  smux,
  yamux;
}

enum WarpDetourMode {
  outbound,
  inbound;

  String present(TranslationsEn t) => switch (this) {
        outbound => t.settings.config.warpDetourModes.outbound,
        inbound => t.settings.config.warpDetourModes.inbound,
      };
}
