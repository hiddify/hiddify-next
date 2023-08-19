// import 'package:flutter/material.dart';
// import 'package:hiddify/core/core_providers.dart';
// import 'package:hiddify/core/prefs/prefs.dart';
// import 'package:hiddify/domain/clash/clash.dart';
// import 'package:hiddify/features/settings/widgets/widgets.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:recase/recase.dart';

// class ClashOverridesPage extends HookConsumerWidget {
//   const ClashOverridesPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = ref.watch(translationsProvider);

//     final overrides =
//         ref.watch(prefsControllerProvider.select((value) => value.clash));
//     final notifier = ref.watch(prefsControllerProvider.notifier);

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             title: Text(t.settings.clash.sectionTitle.titleCase),
//             pinned: true,
//           ),
//           SliverList.list(
//             children: [
//               InputOverrideTile(
//                 title: t.settings.clash.overrides.httpPort,
//                 value: overrides.httpPort,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(httpPort: value),
//                 ),
//               ),
//               InputOverrideTile(
//                 title: t.settings.clash.overrides.socksPort,
//                 value: overrides.socksPort,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(socksPort: value),
//                 ),
//               ),
//               InputOverrideTile(
//                 title: t.settings.clash.overrides.redirPort,
//                 value: overrides.redirPort,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(redirPort: value),
//                 ),
//               ),
//               InputOverrideTile(
//                 title: t.settings.clash.overrides.tproxyPort,
//                 value: overrides.tproxyPort,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(tproxyPort: value),
//                 ),
//               ),
//               InputOverrideTile(
//                 title: t.settings.clash.overrides.mixedPort,
//                 value: overrides.mixedPort,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(mixedPort: value),
//                 ),
//               ),
//               ToggleOverrideTile(
//                 title: t.settings.clash.overrides.allowLan,
//                 value: overrides.allowLan,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(allowLan: value),
//                 ),
//               ),
//               ToggleOverrideTile(
//                 title: t.settings.clash.overrides.ipv6,
//                 value: overrides.ipv6,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(ipv6: value),
//                 ),
//               ),
//               ChoiceOverrideTile(
//                 title: t.settings.clash.overrides.mode,
//                 value: overrides.mode,
//                 options: TunnelMode.values,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(mode: value),
//                 ),
//               ),
//               ChoiceOverrideTile(
//                 title: t.settings.clash.overrides.logLevel,
//                 value: overrides.logLevel,
//                 options: LogLevel.values,
//                 onChange: (value) => notifier.patchClashOverrides(
//                   ClashConfigPatch(logLevel: value),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
