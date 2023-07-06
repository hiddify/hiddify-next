import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/qr_code_scanner_screen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AddProfileModal extends HookConsumerWidget {
  const AddProfileModal({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    const buttonsPadding = 24.0;
    const buttonsGap = 16.0;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // temporary solution, aspect ratio widget relies on height and in a row there no height!
              final buttonWidth = constraints.maxWidth / 2 -
                  (buttonsPadding + (buttonsGap / 2));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: buttonsPadding),
                child: Row(
                  children: [
                    _Button(
                      label: t.profile.add.fromClipboard.sentenceCase,
                      icon: Icons.content_paste,
                      size: buttonWidth,
                      onTap: () async {
                        final captureResult =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        final link =
                            LinkParser.simple(captureResult?.text ?? '');
                        if (link != null && context.mounted) {
                          context.pop();
                          await NewProfileRoute(url: link.url, name: link.name)
                              .push(context);
                        } else {
                          CustomToast.error(
                            t.profile.add.invalidUrlMsg.sentenceCase,
                          ).show(context);
                        }
                      },
                    ),
                    const Gap(buttonsGap),
                    if (!PlatformUtils.isDesktop)
                      _Button(
                        label: t.profile.add.scanQr,
                        icon: Icons.qr_code_scanner,
                        size: buttonWidth,
                        onTap: () async {
                          final captureResult =
                              await const QRCodeScannerScreen().open(context);
                          if (captureResult == null) return;
                          final link = LinkParser.simple(captureResult);
                          if (link != null && context.mounted) {
                            context.pop();
                            await NewProfileRoute(
                              url: link.url,
                              name: link.name,
                            ).push(context);
                          } else {
                            CustomToast.error(
                              t.profile.add.invalidUrlMsg.sentenceCase,
                            ).show(context);
                          }
                        },
                      )
                    else
                      _Button(
                        label: t.profile.add.manually.sentenceCase,
                        icon: Icons.add,
                        size: buttonWidth,
                        onTap: () async {
                          context.pop();
                          await const NewProfileRoute().push(context);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          if (!PlatformUtils.isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: buttonsPadding,
                vertical: 16,
              ),
              child: SizedBox(
                height: 36,
                child: Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                  shadowColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      context.pop();
                      await const NewProfileRoute().push(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(8),
                        Text(
                          t.profile.add.manually.sentenceCase,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Gap(24),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: size / 3,
                color: color,
              ),
              const Gap(16),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
