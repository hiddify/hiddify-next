# Changelog

## Unreleased

### New Features and Improvements

- Changed Responsive UI Behavior
  - Now app is responsive on all platforms with appropriate routing setup.
- Redesigned System Tray on Desktop
  - Options have been simplified and a new mode selector is added for easier access to TUN and Proxy modes.
- Added Auto Connect on Start
  - On desktop, app will try to connect to the last used profile on startup. (if last session was not explicitly disconnected by the user)
- Added AppCast Update Checker
  - Checking for new versions of the app will use a more reliable approach on all platforms.
- Added **winget** Release
  - Now you're able to install and update Hiddify Next on Windows using [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
- Changed in-app Toasts
- Updated Core Sing-box Version to 1.7.0

### Bug Fixes

- Removed **execute config as is** option which caused crashes and confusion for users.
- Fixed android service revoke and restart.
- Fixed github release update checker.
- Fixed translator script. [PR#108](https://github.com/hiddify/hiddify-next/pull/108) by [Hirad Rasoolinejad](https://github.com/Hiiirad)
- Fixed localization mistakes in Chinese. [PR#113](https://github.com/hiddify/hiddify-next/pull/113) and [PR#123](https://github.com/hiddify/hiddify-next/pull/123) by [Nyar233](https://github.com/Nyar233)
- Fixed localization mistakes in Chinese Readme. [PR#137](https://github.com/hiddify/hiddify-next/pull/137) by [wldjdjsks](https://github.com/huajizhige)
- Fixed localization mistakes in Chinese. [PR#138](https://github.com/hiddify/hiddify-next/pull/138) by [wldjdjsks](https://github.com/huajizhige)

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
