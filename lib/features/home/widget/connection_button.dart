import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/connection/widget/experimental_feature_notice.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: rewrite
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);

    ref.listen(
      connectionNotifierProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
        if (next
            case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog.fromErr(t.presentError(connectionFailure))
              .show(context);
        }
      },
    );

    final buttonTheme = Theme.of(context).extension<ConnectionButtonTheme>()!;

    switch (connectionStatus) {
      case AsyncData(value: final status):
        final Color connectionLogoColor = status.isConnected
            ? buttonTheme.connectedColor!
            : buttonTheme.idleColor!;

        return _ConnectionButton(
          onTap: () async {
            var canConnect = true;
            if (status case Disconnected()) {
              final hasExperimental =
                  await ref.read(configOptionNotifierProvider.future).then(
                        (value) => value.hasExperimentalOptions(),
                        onError: (_) => false,
                      );
              final canShowNotice =
                  !ref.read(disableExperimentalFeatureNoticeProvider);

              if (hasExperimental && canShowNotice && context.mounted) {
                canConnect = await const ExperimentalFeatureNoticeDialog()
                        .show(context) ??
                    true;
              }
            }

            if (canConnect) {
              await ref
                  .read(connectionNotifierProvider.notifier)
                  .toggleConnection();
            }
          },
          enabled: !status.isSwitching,
          label: status.present(t),
          buttonColor: connectionLogoColor,
        );
      case AsyncError():
        return _ConnectionButton(
          onTap: () =>
              ref.read(connectionNotifierProvider.notifier).toggleConnection(),
          enabled: true,
          label: const Disconnected().present(t),
          buttonColor: buttonTheme.idleColor!,
        );
      default:
        // HACK
        return _ConnectionButton(
          onTap: () {},
          enabled: false,
          label: "",
          buttonColor: Colors.red,
        );
    }
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.buttonColor,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  color: buttonColor.withOpacity(0.5),
                ),
              ],
            ),
            width: 148,
            height: 148,
            child: Material(
              key: const ValueKey("home_connection_button"),
              shape: const CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Assets.images.logo.svg(
                    colorFilter: ColorFilter.mode(
                      buttonColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ).animate(target: enabled ? 0 : 1).blurXY(end: 1),
          )
              .animate(target: enabled ? 0 : 1)
              .scaleXY(end: .88, curve: Curves.easeIn),
        ),
        const Gap(16),
        ExcludeSemantics(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
