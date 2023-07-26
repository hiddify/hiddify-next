import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'runtime_details.freezed.dart';
part 'runtime_details.g.dart';

// TODO implement clash version
@Riverpod(keepAlive: true)
class RuntimeDetailsNotifier extends _$RuntimeDetailsNotifier with AppLogger {
  @override
  Future<RuntimeDetails> build() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return RuntimeDetails(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      installerStore: packageInfo.installerStore,
      clashVersion: "",
    );
  }
}

@freezed
class RuntimeDetails with _$RuntimeDetails {
  const RuntimeDetails._();

  const factory RuntimeDetails({
    required String version,
    required String buildNumber,
    String? installerStore,
    required String clashVersion,
  }) = _RuntimeDetails;

  String get fullVersion => version + buildNumber;

  factory RuntimeDetails.fromJson(Map<String, dynamic> json) =>
      _$RuntimeDetailsFromJson(json);
}
