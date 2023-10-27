# Changelog

## [0.10.0] - 2023-10-27

### New Features and Improvements

- Added Basic region-based routing rules
  - Based on your selected region (Iran, China or Russia), local ip and domains are bypassed.
- Redesigned Logs page
  - Now you're able to pause stream and clear logs. Also logs are delivered more consistently, with less resource consumption.
- Added tag of selected outbound of selectors to proxies page
  - Selected outbound tag of selectors like URLTests are now shown in other selectors as well.
- Added color to delay number in proxies page
- Memory limit option
  - Limit sing-box core memory usage.
- Revamped theme preferences settings
- Added initial iOS implementation. [PR#98](https://github.com/hiddify/hiddify-next/pull/98) by [GFWFighter](https://github.com/GFWFighter)
- Added Russian region
- Added Terms and Conditions and Privacy policy to about page

### Bug Fixes

- Removed reconnection on auto profile updates
- Fixed filtering logs by level
- Fixed localization mistakes in Russian. [PR#95](https://github.com/hiddify/hiddify-next/pull/95) by [solokot](https://github.com/solokot)
- Fixed localization mistakes in Russian. [PR#74](https://github.com/hiddify/hiddify-next/pull/74) by [Elshad Guseynov](https://github.com/lifeindarkside)

[0.10.0]: https://github.com/hiddify/hiddify-next/releases/tag/0.10.0
