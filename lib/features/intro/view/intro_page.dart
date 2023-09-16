import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

class IntroPage extends HookConsumerWidget with PresLogger {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          const SliverGap(24),
          SliverToBoxAdapter(
            child: SizedBox(
              width: 248,
              height: 248,
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Assets.images.logo.svg(),
              ),
            ),
          ),
          SliverCrossAxisConstrained(
            maxCrossAxisExtent: 368,
            child: MultiSliver(
              children: [
                const LocalePrefTile(),
                const SliverGap(8),
                const EnableAnalyticsPrefTile(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: FilledButton(
                    onPressed: () async {
                      if (!ref.read(enableAnalyticsProvider)) {
                        loggy.debug("disabling analytics per user request");
                        await Sentry.close();
                      }
                      await ref
                          .read(introCompletedProvider.notifier)
                          .update(true);
                    },
                    child: Text(t.intro.start),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
