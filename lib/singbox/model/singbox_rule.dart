import 'package:dart_mappable/dart_mappable.dart';

part 'singbox_rule.mapper.dart';

@MappableClass()
class SingboxRule with SingboxRuleMappable {
  const SingboxRule({
    this.domains,
    this.ip,
    this.port,
    this.protocol,
    this.network = RuleNetwork.tcpAndUdp,
    this.outbound = RuleOutbound.proxy,
  });

  final String? domains;
  final String? ip;
  final String? port;
  final String? protocol;
  final RuleNetwork network;
  final RuleOutbound outbound;
}

@MappableEnum()
enum RuleOutbound { proxy, bypass, block }

@MappableEnum()
enum RuleNetwork {
  @MappableValue("")
  tcpAndUdp,

  @MappableValue("tcp")
  tcp,

  @MappableValue("udp")
  udp;
}
