import 'package:flutter/material.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/proxies/notifier/notifier.dart';
import 'package:hiddify/features/proxies/notifier/proxies_delay_notifier.dart';
import 'package:hiddify/features/proxies/widgets/widgets.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ProxiesPage extends HookConsumerWidget with PresLogger {
  const ProxiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final asyncProxies = ref.watch(proxiesNotifierProvider);
    final notifier = ref.watch(proxiesNotifierProvider.notifier);
    final delays = ref.watch(proxiesDelayNotifierProvider);

    final selectActiveProxyMutation = useMutation(
      initialOnFailure: (error) =>
          CustomToast.error(t.printError(error)).show(context),
    );

    switch (asyncProxies) {
      case AsyncData(value: final groups):
        if (groups.isEmpty) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                NestedTabAppBar(
                  title: Text(t.proxies.pageTitle.titleCase),
                ),
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.proxies.emptyProxiesMsg.titleCase),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final select = groups.first;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.proxies.pageTitle.titleCase),
                actions: [
                  PopupMenuButton(
                    itemBuilder: (_) {
                      return [
                        PopupMenuItem(
                          onTap: ref
                              .read(proxiesDelayNotifierProvider.notifier)
                              .cancelDelayTest,
                          child: Text(
                            t.proxies.cancelTestButtonText.sentenceCase,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  if (!PlatformUtils.isDesktop && width < 648) {
                    return SliverList.builder(
                      itemBuilder: (_, index) {
                        final proxy = select.proxies[index];
                        return ProxyTile(
                          proxy,
                          selected: select.group.now == proxy.name,
                          delay: delays[proxy.name],
                          onSelect: () async {
                            if (selectActiveProxyMutation.state.isInProgress) {
                              return;
                            }
                            selectActiveProxyMutation.setFuture(
                              notifier.changeProxy(
                                select.group.name,
                                proxy.name,
                              ),
                            );
                          },
                        );
                      },
                      itemCount: select.proxies.length,
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (width / 268).floor(),
                      mainAxisExtent: 68,
                    ),
                    itemBuilder: (context, index) {
                      final proxy = select.proxies[index];
                      return ProxyTile(
                        proxy,
                        selected: select.group.now == proxy.name,
                        delay: delays[proxy.name],
                        onSelect: () async {
                          if (selectActiveProxyMutation.state.isInProgress) {
                            return;
                          }
                          selectActiveProxyMutation.setFuture(
                            notifier.changeProxy(
                              select.group.name,
                              proxy.name,
                            ),
                          );
                        },
                      );
                    },
                    itemCount: select.proxies.length,
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async =>
                // TODO: improve
                ref.read(proxiesDelayNotifierProvider.notifier).testDelay(
                      select.proxies.map((e) => e.name),
                    ),
            tooltip: t.proxies.delayTestTooltip.titleCase,
            child: const Icon(Icons.bolt),
          ),
        );

      case AsyncError(:final error):
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.proxies.pageTitle.titleCase),
              ),
              SliverErrorBodyPlaceholder(
                t.printError(error),
                icon: null,
              ),
            ],
          ),
        );

      case AsyncLoading():
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.proxies.pageTitle.titleCase),
              ),
              const SliverLoadingBodyPlaceholder(),
            ],
          ),
        );

      // TODO: remove
      default:
        return const Scaffold();
    }
  }
}
