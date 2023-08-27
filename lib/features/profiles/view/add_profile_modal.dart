import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/qr_code_scanner_screen.dart';
import 'package:hiddify/features/profiles/notifier/notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AddProfileModal extends HookConsumerWidget {
  const AddProfileModal({
    super.key,
    this.url,
    this.scrollController,
  });

  final String? url;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final mutationTriggered = useState(false);
    final addProfileMutation = useMutation(
      initialOnFailure: (err) {
        mutationTriggered.value = false;
        // CustomToast.error(t.presentError(err)).show(context);
        CustomAlertDialog.fromErr(t.presentError(err)).show(context);
      },
      initialOnSuccess: () {
        CustomToast.success(t.profile.save.successMsg.sentenceCase)
            .show(context);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (context.mounted) context.pop();
          },
        );
      },
    );

    final showProgressIndicator =
        addProfileMutation.state.isInProgress || mutationTriggered.value;

    useMemoized(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (url != null && context.mounted) {
        addProfileMutation.setFuture(
          ref.read(profilesNotifierProvider.notifier).addProfile(url!),
        );
      }
    });

    final theme = Theme.of(context);
    const buttonsPadding = 24.0;
    const buttonsGap = 16.0;

    return SingleChildScrollView(
      controller: scrollController,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // temporary solution, aspect ratio widget relies on height and in a row there no height!
            final buttonWidth =
                constraints.maxWidth / 2 - (buttonsPadding + (buttonsGap / 2));

            return AnimatedCrossFade(
              firstChild: SizedBox(
                height: buttonWidth.clamp(0, 168),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.profile.add.addingProfileMsg.sentenceCase,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Gap(8),
                      const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              secondChild: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: buttonsPadding),
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
                                LinkParser.parse(captureResult?.text ?? '');
                            if (link != null && context.mounted) {
                              if (addProfileMutation.state.isInProgress) return;
                              mutationTriggered.value = true;
                              addProfileMutation.setFuture(
                                ref
                                    .read(profilesNotifierProvider.notifier)
                                    .addProfile(link.url),
                              );
                            } else {
                              if (context.mounted) {
                                CustomToast.error(
                                  t.profile.add.invalidUrlMsg.sentenceCase,
                                ).show(context);
                              }
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
                                  await const QRCodeScannerScreen()
                                      .open(context);
                              if (captureResult == null) return;
                              final link = LinkParser.simple(captureResult);
                              if (link != null && context.mounted) {
                                if (addProfileMutation.state.isInProgress) {
                                  return;
                                }
                                mutationTriggered.value = true;
                                addProfileMutation.setFuture(
                                  ref
                                      .read(profilesNotifierProvider.notifier)
                                      .addProfile(link.url),
                                );
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
                          color: theme.colorScheme.surface,
                          surfaceTintColor: theme.colorScheme.surfaceTint,
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
                                  color: theme.colorScheme.primary,
                                ),
                                const Gap(8),
                                Text(
                                  t.profile.add.manually.sentenceCase,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
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
              crossFadeState: showProgressIndicator
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            );
          },
        ),
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
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        elevation: 8,
        color: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
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
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
