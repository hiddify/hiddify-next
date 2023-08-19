import 'package:flutter/material.dart';

enum TunnelMode {
  rule,
  global,
  direct;
}

enum LogLevel {
  info,
  warning,
  error,
  debug,
  silent;

  Color get color => switch (this) {
        info => Colors.lightGreen,
        warning => Colors.orangeAccent,
        error => Colors.redAccent,
        debug => Colors.lightBlue,
        _ => Colors.white,
      };
}

enum ProxyType {
  direct("Direct"),
  reject("Reject"),
  compatible("Compatible"),
  pass("Pass"),
  shadowSocks("ShadowSocks"),
  shadowSocksR("ShadowSocksR"),
  snell("Snell"),
  socks5("Socks5"),
  http("Http"),
  vmess("Vmess"),
  vless("Vless"),
  trojan("Trojan"),
  hysteria("Hysteria"),
  wireGuard("WireGuard"),
  tuic("Tuic"),
  ssh("SSH"),
  relay("Relay"),
  selector("Selector"),
  fallback("Fallback"),
  urlTest("URLTest", "urltest"),
  loadBalance("LoadBalance"),
  unknown("Unknown");

  const ProxyType(this.label, [this._key]);

  final String? _key;
  final String label;

  String get key => _key ?? name;

  static List<ProxyType> groupValues = [
    selector,
    fallback,
    urlTest,
    loadBalance,
  ];
}
