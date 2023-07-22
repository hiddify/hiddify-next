# Hiddify Next

<p align="center"><img src="assets/images/logo.svg" width="168"/></p>

<p align="center" style="font-size: 20px">Hiddify Multi-platform Proxy Client</p>
<p align="center" style="font-size: 20px">⚠️Hiddify Next is still in early development phase⚠️</p>
<p align="center" style="font-size: 16px">Windows, Android, Linux are supported (macOS and iOS is coming soon)</p>

## Build from source

### requirements:
  - GO v1.19+
  - Flutter v3.10+
  - Make
  - GCC
  - MinGW-w64
  - Android SDK (with CMake and NDK)

  This project uses [flutter_distributor](https://github.com/leanflutter/flutter_distributor) for packaging.

  ```shell
  # fetch dependencies and build generated files
  $ make get gen

  # build clash native library for all supported platforms and architectures
  $ make android-libs windows-libs

  # build apk for android
  $ make release-android

  # build windows executable
  $ flutter_distributor package --platform windows --targets exe
  ```

## Acknowledgements
  - [Clash](https://github.com/Dreamacro/clash)
  - [Clash Meta](https://github.com/MetaCubeX/Clash.Meta)
  - [FClash](https://github.com/Fclash/Fclash)
