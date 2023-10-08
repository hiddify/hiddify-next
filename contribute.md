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

## Collaboration and Contact Information 
We need your collaboration in order to develop this project. If you are specialists in these areas, please do not hesitate to contact us.

* Flutter Developing
* Swift Developing 
* Kotlin Developing 
* Go Developing
<div align=center>


</br>

[![Email](https://img.shields.io/badge/Email-contribute@hiddify.com-005FF9?style=flat-square&logo=mail.ru)](mailto:contribute@hiddify.com)
[![Telegram Channel](https://img.shields.io/endpoint?label=Channel&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify&color=blue)](https://telegram.dog/hiddify)
[![Telegram Group](https://img.shields.io/endpoint?color=neon&label=Support%20Group&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fhiddify_board)](https://telegram.dog/hiddify_board)
[![Youtube](https://img.shields.io/youtube/channel/views/UCxrmeMvVryNfB4XL35lXQNg?label=Youtube&style=flat-square&logo=youtube)](https://www.youtube.com/@hiddify)
[![Twitter](https://img.shields.io/twitter/follow/hiddify_com?color=%231DA1F2&logo=twitter&logoColor=1DA1F2&style=flat-square)](https://twitter.com/intent/follow?screen_name=hiddify_com)

</div>
