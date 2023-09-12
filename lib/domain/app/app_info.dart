import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/domain/environment.dart';

part 'app_info.freezed.dart';
part 'app_info.g.dart';

@freezed
class AppInfo with _$AppInfo {
  const AppInfo._();

  const factory AppInfo({
    required String name,
    required String version,
    required String buildNumber,
    String? installerMedia,
    required String operatingSystem,
    required Environment environment,
  }) = _AppInfo;

  String get userAgent => "HiddifyNext/$version ($operatingSystem)";

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);
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
