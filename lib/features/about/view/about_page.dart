import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/new_version_dialog.dart';
import 'package:hiddify/features/common/runtime_details.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final appVersion = ref.watch(appVersionProvider);

    final isCheckingForUpdate = ref.watch(
      runtimeDetailsNotifierProvider.select(
        (value) => value.maybeWhen(
          data: (data) => data.latestVersion.isLoading,
          orElse: () => false,
        ),
      ),
    );

    ref.listen(
      runtimeDetailsNotifierProvider,
      (_, next) async {
        if (next case AsyncData(:final value)) {
          switch (value.latestVersion) {
            case AsyncError(:final error):
              CustomToast.error(t.printError(error)).show(context);
            default:
              if (value.newVersionAvailable) {
                await NewVersionDialog(
                  value.appVersion,
                  value.latestVersion.value!,
                  canIgnore: false,
                ).show(context);
              }
          }
        }
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(t.about.pageTitle.titleCase),
          ),
          ...switch (appVersion) {
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
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        title: Text(t.about.sourceCode.sentenceCase),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                          await UriUtils.tryLaunch(
                            Uri.parse(Constants.githubUrl),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(t.about.telegramChannel.sentenceCase),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () async {
                          await UriUtils.tryLaunch(
                            Uri.parse(Constants.telegramChannelUrl),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(t.about.checkForUpdate.sentenceCase),
                        trailing: isCheckingForUpdate
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : const Icon(Icons.update),
                        onTap: () async {
                          await ref
                              .read(runtimeDetailsNotifierProvider.notifier)
                              .checkForUpdates();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            _ => [],
          },
        ],
      ),
    );
  }
}
