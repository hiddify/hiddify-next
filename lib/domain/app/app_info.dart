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
    required Release release,
    required String operatingSystem,
    required String operatingSystemVersion,
    required Environment environment,
  }) = _AppInfo;

  String get userAgent => "HiddifyNext/$version ($operatingSystem)";

  String get presentVersion => environment == Environment.prod
      ? version
      : "$version ${environment.name}";

  /// formats app info for sharing
  String format() => '''
$name v$version ($buildNumber) [${environment.name}]
${release.name} release
$operatingSystem [$operatingSystemVersion]''';

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
    required String url,
    required DateTime publishedAt,
    required Environment flavor,
  }) = _RemoteVersionInfo;

  String get presentVersion =>
      flavor == Environment.prod ? version : "$version ${flavor.name}";

  // ignore: prefer_constructors_over_static_methods
  static RemoteVersionInfo fromJson(Map<String, dynamic> json) {
    final fullTag = json['tag_name'] as String;
    final fullVersion = fullTag.removePrefix("v").split("-").first.split("+");
    var version = fullVersion.first;
    var buildNumber = fullVersion.elementAtOrElse(1, (index) => "");
    var flavor = Environment.prod;
    for (final env in Environment.values) {
      final suffix = ".${env.name}";
      if (version.endsWith(suffix)) {
        version = version.removeSuffix(suffix);
        flavor = env;
        break;
      } else if (buildNumber.endsWith(suffix)) {
        buildNumber = buildNumber.removeSuffix(suffix);
        flavor = env;
        break;
      }
    }
    final preRelease = json["prerelease"] as bool;
    final publishedAt = DateTime.parse(json["published_at"] as String);
    return RemoteVersionInfo(
      version: version,
      buildNumber: buildNumber,
      releaseTag: fullTag,
      preRelease: preRelease,
      url: json["html_url"] as String,
      publishedAt: publishedAt,
      flavor: flavor,
    );
  }
}
