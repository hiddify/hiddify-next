# Contributing

Every contribution to Hiddify Next is welcome, whether it is reporting a bug, submitting a fix, proposing new features, or just asking a question. To make contributing to Hiddify Next as easy as possible, you will find more details for the development flow in this documentation.

Please note, we have a [Code of Conduct](https://github.com/hiddify/hiddify-next/blob/main/CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

- [Feedback, Issues and Questions](#feedback-issues-and-questions)
- [Adding new Features](#adding-new-features)
- [Development](#development)
  - [Working with the Go Code](#working-with-the-go-code)
  - [Working with the Flutter Code](#working-with-the-flutter-code)
    - [Setting up the Environment](#setting-up-the-environment)
    - [Run Release Build on a Device](#run-release-build-on-a-device)
- [Release](#release)
- [Collaboration and Contact Information](#collaboration-and-contact-information)

## Feedback, Issues and Questions

If you encounter any issue, or you have an idea to improve, please:

- Search through [existing open and closed GitHub Issues](https://github.com/hiddify/hiddify-next/issues) for the answer first. If you find a relevant topic, please comment on the issue.
- If none of the issues are relevant, please add a new [issue](https://github.com/hiddify/hiddify-next/issues/new/choose) following the templates and provide as much relevant information as possible.

## Adding new Features

When contributing a complex change to the Hiddify Next repository, please discuss the change you wish to make within a GitHub issue with the owners of this repository before making the change.

## Development

Hiddify Next uses [Flutter](https://flutter.dev) and [Go](https://go.dev), make sure that you have the correct version installed before starting development. You can use the following commands to check your installed version:

```shell
$ flutter --version

# example response
Flutter 3.13.4 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 367f9ea16b (4 weeks ago) • 2023-09-12 23:27:53 -0500
Engine • revision 9064459a8b
Tools • Dart 3.1.2 • DevTools 2.25.0


$ go version

# example response
go version go1.21.1 darwin/arm64
```

### Working with the Go Code

> if you're not interested in building/contributing to the Go code, you can skip this section

The Go code for Hiddify Next can be found in the `libcore` folder, as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) and in [core repository](https://github.com/hiddify/hiddify-next-core). The entrypoints for the desktop version are available in the [`libcore/custom`](https://github.com/hiddify/hiddify-next-core/tree/main/custom) folder and for the mobile version they can be found in the [`libcore/mobile`](https://github.com/hiddify/hiddify-next-core/tree/main/mobile) folder.

For the desktop version, we have to compile the Go code into a C shared library. We are providing a Makefile to generate the C shared libraries for all operating systems. The following Make commands will build libcore and copy the resulting output in [`libcore/bin`](https://github.com/hiddify/hiddify-next-core/tree/main/bin):

- `make windows-amd64`
- `make linux-amd64`
- `make macos-universal`

For the mobile version, we are using the [`gomobile`](https://github.com/golang/go/wiki/Mobile) tools. The following Make commands will build libcore for Android and iOS and copy the resulting output in [`libcore/bin`](https://github.com/hiddify/hiddify-next-core/tree/main/bin):

- `make android`
- `make ios`

### Working with the Flutter Code

We recommend using [Visual Studio Code](https://docs.flutter.dev/development/tools/vs-code) extensions for development.

#### Setting up the Environment

We have extensive use of code generation in the form of [freezed](https://github.com/rrousselGit/freezed), [riverpod](https://github.com/rrousselGit/riverpod), etc. So it's generate these before running the code. Execute the following make commands in order:

```shell
# fetch dependencies
$ make get

# generate translations
$ make translate

# fetch geo assets
$ make get-geo-assets

# generate dart code using build_runner
$ make gen
```

Assuming you have not built the `libcore` and want to use [existing releases](https://github.com/hiddify/hiddify-next-core/releases), you should run the following command (based on your target platform):

- `make windows-libs`
- `make linux-libs`
- `make macos-libs`
- `make android-libs`
- `make ios-libs`

If you want to build the `libcore` from source, prefix the above command with `build-` like `make build-windows-libs`.

#### Run Release Build on a Device

To run the release build on a device for testing, we have to get the Device ID first by running the following command:

```shell
$ flutter devices

# example response
3 connected devices:

2211143G (mobile) • 35492ae2 • android-arm64  • Android 13 (API 33)
Windows (desktop) • windows  • windows-x64    • Microsoft Windows [Version 10.0.22000.2482]
Chrome (web)      • chrome   • web-javascript • Google Chrome 117.0.5938.149
```

Then we can use one of the listed devices and execute the following command to build and run the app on this device:

```shell
flutter run --release --target lib/main_dev.dart --device-id=35492ae2
```

## Release

We use [flutter_distributor](https://github.com/leanflutter/flutter_distributor) for packaging. [GitHub action](https://github.com/hiddify/hiddify-next/blob/main/.github/workflows/build.yml) is triggered on every release tag and will create a new GitHub release.
After setting up the environment, use the following make commands to build the release version:

- `make windows-release`
- `make linux-release`
- `make macos-release`
- `make android-release`
- `make ios-release`

## Collaboration and Contact Information

We need your collaboration in order to develop this project. If you have experience in these areas, please do not hesitate to contact us.

- Flutter Developing
- Swift Developing
- Kotlin Developing
- Go Developing

<div align=center>
</br>

[![Email](https://img.shields.io/badge/Email-contribute@hiddify.com-005FF9?style=flat-square&logo=mail.ru)](mailto:contribute@hiddify.com)
[![Telegram Channel](https://img.shields.io/endpoint?label=Channel&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify&color=blue)](https://telegram.dog/hiddify)
[![Telegram Group](https://img.shields.io/endpoint?color=neon&label=Support%20Group&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify_board)](https://telegram.dog/hiddify_board)
[![Youtube](https://img.shields.io/youtube/channel/views/UCxrmeMvVryNfB4XL35lXQNg?label=Youtube&style=flat-square&logo=youtube)](https://www.youtube.com/@hiddify)
[![Twitter](https://img.shields.io/twitter/follow/hiddify_com?color=%231DA1F2&logo=twitter&logoColor=1DA1F2&style=flat-square)](https://twitter.com/intent/follow?screen_name=hiddify_com)

</div>
