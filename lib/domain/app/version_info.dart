import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'version_info.freezed.dart';
part 'version_info.g.dart';

@freezed
class InstalledVersionInfo with _$InstalledVersionInfo {
  const InstalledVersionInfo._();

  const factory InstalledVersionInfo({
    required String version,
    required String buildNumber,
    String? installerMedia,
  }) = _InstalledVersionInfo;

  String get fullVersion =>
      buildNumber.isBlank ? version : "$version+$buildNumber";

  factory InstalledVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$InstalledVersionInfoFromJson(json);
}

// TODO ignore drafts
@Freezed()
class RemoteVersionInfo with _$RemoteVersionInfo {
  const RemoteVersionInfo._();

  const factory RemoteVersionInfo({
    required String version,
    required String buildNumber,
    required String releaseTag,
    required bool preRelease,
    required DateTime publishedAt,
  }) = _RemoteVersionInfo;

  String get fullVersion =>
      buildNumber.isBlank ? version : "$version+$buildNumber";

  // ignore: prefer_constructors_over_static_methods
  static RemoteVersionInfo fromJson(Map<String, dynamic> json) {
    final fullTag = json['tag_name'] as String;
    final fullVersion = fullTag.removePrefix("v").split("-").first.split("+");
    final version = fullVersion.first;
    final buildNumber = fullVersion.elementAtOrElse(1, (index) => "");
    final preRelease = json["prerelease"] as bool;
    final publishedAt = DateTime.parse(json["published_at"] as String);
    return RemoteVersionInfo(
      version: version,
      buildNumber: buildNumber,
      releaseTag: fullTag,
      preRelease: preRelease,
      publishedAt: publishedAt,
    );
  }
}
