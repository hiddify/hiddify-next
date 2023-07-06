import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/theme/theme.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: rewrite
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectivityControllerProvider);

    final Color connectionLogoColor = connectionStatus.isConnected
        ? ConnectionButtonColor.connected
        : ConnectionButtonColor.disconnected;

    final bool intractable = !connectionStatus.isSwitching;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: connectionLogoColor.withOpacity(0.5),
              ),
            ],
          ),
          width: 148,
          height: 148,
          child: Material(
            shape: const CircleBorder(),
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                await ref
                    .read(connectivityControllerProvider.notifier)
                    .toggleConnection();
              },
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Assets.images.logo.svg(
                  colorFilter: ColorFilter.mode(
                    connectionLogoColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ).animate(target: intractable ? 0 : 1).blurXY(end: 1),
        ).animate(target: intractable ? 0 : 1).scaleXY(end: .88),
        const Gap(16),
        Text(
          connectionStatus.present(t),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
