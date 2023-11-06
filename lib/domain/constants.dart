abstract class Constants {
  static const appName = "Hiddify Next";
  static const geoipFileName = "geoip.db";
  static const geositeFileName = "geosite.db";
  static const configsFolderName = "configs";
  static const localHost = "127.0.0.1";
  static const githubUrl = "https://github.com/hiddify/hiddify-next";
  static const githubReleasesApiUrl =
      "https://api.github.com/repos/hiddify/hiddify-next/releases";
  static const githubLatestReleaseUrl =
      "https://github.com/hiddify/hiddify-next/releases/latest";
  static const appCastUrl =
      "https://raw.githubusercontent.com/hiddify/hiddify-next/main/appcast.xml";
  static const telegramChannelUrl = "https://t.me/hiddify";
  static const privacyPolicyUrl = "https://hiddify.com/en/privacy-policy/";
  static const termsAndConditionsUrl = "https://hiddify.com/terms/";
}

abstract class Defaults {
  static const clashApiPort = 9090;
  static const mixedPort = 2334;
  static const connectionTestUrl = "https://www.gstatic.com/generate_204";
  static const concurrentTestCount = 5;
}
