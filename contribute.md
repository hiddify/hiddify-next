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
