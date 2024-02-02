import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/common/general_pref_tiles.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class IntroPage extends HookConsumerWidget with PresLogger {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final isStarting = useState(false);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: 224,
                height: 224,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Assets.images.logo.svg(),
                ),
              ),
            ),
            SliverCrossAxisConstrained(
              maxCrossAxisExtent: 368,
              child: MultiSliver(
                children: [
                  const LocalePrefTile(),
                  const SliverGap(4),
                  const RegionPrefTile(),
                  const SliverGap(4),
                  const EnableAnalyticsPrefTile(),
                  const SliverGap(4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text.rich(
                      t.intro.termsAndPolicyCaution(
                        tap: (text) => TextSpan(
                          text: text,
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await UriUtils.tryLaunch(
                                Uri.parse(Constants.termsAndConditionsUrl),
                              );
                            },
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: FilledButton(
                      onPressed: () async {
                        if (isStarting.value) return;
                        isStarting.value = true;
                        if (!ref
                            .read(analyticsControllerProvider)
                            .requireValue) {
                          loggy.info("disabling analytics per user request");
                          try {
                            await ref
                                .read(analyticsControllerProvider.notifier)
                                .disableAnalytics();
                          } catch (error, stackTrace) {
                            loggy.error(
                              "could not disable analytics",
                              error,
                              stackTrace,
                            );
                          }
                        }
                        await ref
                            .read(introCompletedProvider.notifier)
                            .update(true);
                      },
                      child: isStarting.value
                          ? LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : Text(t.intro.start),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
