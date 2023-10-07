[**![Lang_farsi](https://user-images.githubusercontent.com/125398461/234186932-52f1fa82-52c6-417f-8b37-08fe9250a55f.png) &nbsp;فارسی**](README_fa.md)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<p align="center"><img src="assets/images/logo.svg" width="168"/></p>

<p align="center">
   
[![Downloads](https://static.pepy.tech/badge/hiddifypanel?style=flat-square&v3)](https://pepy.tech/project/hiddifypanel?display=monthly&versions=2.*&versions=1.*&versions=3.*)[![Last Version](https://img.shields.io/github/release/hiddify/hiddify-next/all.svg?style=flat-square)](https://github.com/hiddify/hiddify-server/)[![Last Release Date](https://img.shields.io/github/release-date/hiddify/hiddify-next.svg?style=flat-square)](https://github.com/hiddify/hiddify-next/)![commits](https://img.shields.io/github/commit-activity/m/hiddify/hiddify-next?style=flat-square)[![Youtube](https://img.shields.io/youtube/channel/views/UCxrmeMvVryNfB4XL35lXQNg?label=Youtube&style=flat-square&logo=youtube)](https://www.youtube.com/@hiddify)[![Telegram Channel](https://img.shields.io/endpoint?label=Channel&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify&color=blue)](https://telegram.dog/hiddify)[![Telegram Group](https://img.shields.io/endpoint?color=neon&label=Support%20Group&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify_board)](https://telegram.dog/hiddify_board)

</p>

<p align="center" style="font-size: 16px">Multi-platform, Sing-box (universal proxy toolchain) client</p>

## 🚀 Main features:

⭐  Ease of use with a simple UI

✈️ Multi-platform support: Android, Windows, Linux and macOS (PRs for iOS are welcome)

⚙️ App based on Sing-box

🔍 Auto selection of the best server and config

🟡 Supporting a wide range of protocols: 
Sing-box, V2ray, Xray, Vless, Vmess, Reality, TUIC, Hysteria, Shadowtls, SSH, Clash, Clash meta

🟡 Supporting different subscription links:
Clash, Sing-box and Shadowsocks

🔄 Automatic update of subscription link and configurations 

🔎 Display profile information including remaining day and traffic 

📱 Completely free and without any ads and interruptions

🛡 Open source and completely secure

🌙 Dark and light modes

⚙ Compatible with all panels

⭐ Appropriate configuration for Iran, China, Russia and other countries


💻 Release of Android version on [Google Play](https://play.google.com/store/apps/details?id=app.hiddify.com)



## Download

For latest releases (including pre-releases), visit [releases page](https://github.com/hiddify/hiddify-next/releases)

- Android: [Universal](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-android-universal.apk) - [Arm64](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-android-arm64.apk) - [Arm7](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-android-arm7.apk) - [x86_64](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-android-x86_64.apk)

- Windows: [x64 Setup](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-windows-x64-setup.exe) - [x64 Portable](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-windows-x64-portable.zip)

- Linux: [x64 AppImage](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-linux-x64.AppImage.zip)

- macOS: [Universal (x64, M series)](https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-macos-universal.dmg)

## Build from source

Hiddify Next relies on [core library](https://github.com/hiddify/hiddify-next-core) made with GO. if you're interested in building/contributing to that as well follow instructions there.

### requirements:

- Flutter v3.13+
- Make
- Android SDK

This project uses [flutter_distributor](https://github.com/leanflutter/flutter_distributor) for packaging.

```shell
# fetch dependencies and build generated files
$ make get translate gen

# fetch geo assets
$ make get-geo-assets

for platform in [windows linux macos android]:
   # fetch native libraries for respective platforms, follow core lib instructions for building
   $ make $platform-libs
   $ make release-$platform

# example:
   $ make windows-libs
   $ make windows-release
```

## Acknowledgements

- [Singbox](https://github.com/SagerNet/sing-box)
- [Clash](https://github.com/Dreamacro/clash)
- [Clash Meta](https://github.com/MetaCubeX/Clash.Meta)
- [FClash](https://github.com/Fclash/Fclash)
- [Others](./pubspec.yaml)
