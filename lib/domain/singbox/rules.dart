import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/prefs/locale_prefs.dart';

part 'rules.freezed.dart';
part 'rules.g.dart';

@freezed
class Rule with _$Rule {
  @JsonSerializable(fieldRename: FieldRename.kebab)
  const factory Rule({
    required String id,
    required String name,
    @Default(false) bool enabled,
    String? domains,
    String? ip,
    String? port,
    String? protocol,
    @Default(RuleNetwork.tcpAndUdp) RuleNetwork network,
    @Default(RuleOutbound.proxy) RuleOutbound outbound,
  }) = _Rule;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
}

enum RuleOutbound { proxy, bypass, block }

@JsonEnum(valueField: 'key')
enum RuleNetwork {
  tcpAndUdp(""),
  tcp("tcp"),
  udp("udp");

  const RuleNetwork(this.key);

  final String? key;
}

enum PerAppProxyMode {
  off,
  include,
  exclude;

  bool get enabled => this != off;

  ({String title, String message}) present(TranslationsEn t) => switch (this) {
        off => (
            title: t.settings.network.perAppProxyModes.off,
            message: t.settings.network.perAppProxyModes.offMsg,
          ),
        include => (
            title: t.settings.network.perAppProxyModes.include,
            message: t.settings.network.perAppProxyModes.includeMsg,
          ),
        exclude => (
            title: t.settings.network.perAppProxyModes.exclude,
            message: t.settings.network.perAppProxyModes.excludeMsg,
          ),
      };
}

enum Region {
  ir,
  cn,
  ru,
  other;

  String present(TranslationsEn t) => switch (this) {
        ir => t.settings.general.regions.ir,
        cn => t.settings.general.regions.cn,
        ru => t.settings.general.regions.ru,
        other => t.settings.general.regions.other,
      };
}
