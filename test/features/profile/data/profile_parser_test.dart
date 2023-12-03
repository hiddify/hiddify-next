import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/profile/data/profile_parser.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';

void main() {
  const validBaseUrl = "https://example.com/configurations/user1/filename.yaml";
  const validExtendedUrl =
      "https://example.com/configurations/user1/filename.yaml?test#b";
  const validSupportUrl = "https://example.com/support";

  group(
    "parse",
    () {
      test(
        "url with file extension, no headers",
        () {
          final profile = ProfileParser.parse(validBaseUrl, {});

          expect(profile.name, equals("filename"));
          expect(profile.url, equals(validBaseUrl));
          expect(profile.options, isNull);
          expect(profile.subInfo, isNull);
        },
      );

      test(
        "url with url, no headers",
        () {
          final profile = ProfileParser.parse(validExtendedUrl, {});

          expect(profile.name, equals("b"));
          expect(profile.url, equals(validExtendedUrl));
          expect(profile.options, isNull);
          expect(profile.subInfo, isNull);
        },
      );

      test(
        "with base64 profile-title header",
        () {
          final headers = <String, List<String>>{
            "profile-title": ["base64:ZXhhbXBsZVRpdGxl"],
            "profile-update-interval": ["1"],
            "subscription-userinfo": [
              "upload=0;download=1024;total=10240.5;expire=1704054600.55",
            ],
            "profile-web-page-url": [validBaseUrl],
            "support-url": [validSupportUrl],
          };
          final profile = ProfileParser.parse(validExtendedUrl, headers);

          expect(profile.name, equals("exampleTitle"));
          expect(profile.url, equals(validExtendedUrl));
          expect(
            profile.options,
            equals(const ProfileOptions(updateInterval: Duration(hours: 1))),
          );
          expect(
            profile.subInfo,
            equals(
              SubscriptionInfo(
                upload: 0,
                download: 1024,
                total: 10240,
                expire: DateTime(2024),
                webPageUrl: validBaseUrl,
                supportUrl: validSupportUrl,
              ),
            ),
          );
        },
      );
    },
  );
}
