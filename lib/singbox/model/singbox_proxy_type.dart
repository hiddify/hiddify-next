enum ProxyType {
  direct("Direct"),
  block("Block"),
  dns("DNS"),
  socks("SOCKS"),
  http("HTTP"),
  shadowsocks("Shadowsocks"),
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
  hysteria2("Hysteria2"),

  selector("Selector"),
  urltest("URLTest"),
  warp("Warp"),
  unknown("Unknown");

  const ProxyType(this.label);

  final String label;

  String get key => name;

  static List<ProxyType> groupValues = [selector, urltest];

  bool get isGroup => ProxyType.groupValues.contains(this);
}
