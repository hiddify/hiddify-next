import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/features/common/runtime_details.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final details = ref.watch(runtimeDetailsNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(t.about.pageTitle.titleCase),
          ),
          ...switch (details) {
            AsyncData(:final value) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.images.logo.svg(width: 64, height: 64),
                        const Gap(16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.general.appTitle.titleCase,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Gap(4),
                            Text(
                              "${t.about.version} ${value.version} ${value.buildNumber}",
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        title: Text(t.about.whatsNew.sentenceCase),
                      ),
                      ListTile(
                        title: Text(t.about.sourceCode.sentenceCase),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(Constants.githubUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      ListTile(
                        title: Text(t.about.telegramChannel.sentenceCase),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(Constants.telegramChannelUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      ListTile(
                        title: Text(t.about.checkForUpdate.sentenceCase),
                      ),
                    ],
                  ),
                ),
              ],
            _ => [],
          }
        ],
      ),
    );
  }
}
