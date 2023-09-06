enum ProxyType {
  direct("Direct"),
  block("Block"),
  dns("DNS"),
  socks("SOCKS"),
  http("HTTP"),
  vmess("VMess"),
  trojan("Trojan"),
  naive("Naive"),
  wireguard("WireGuard"),
  hysteria("Hysteria"),
  tor("Tor"),
  ssh("SSH"),
  shadowtls("ShadowTLS"),
  shadowsocksr("ShadowsocksR"),
  vless("VLESS"),
  tuic("TUIC"),

  selector("Selector"),
  urltest("URLTest"),

  unknown("Unknown");

  const ProxyType(this.label);

  final String label;

  String get key => name;

  static List<ProxyType> groupValues = [selector, urltest];

  bool get isGroup => ProxyType.groupValues.contains(this);
}
