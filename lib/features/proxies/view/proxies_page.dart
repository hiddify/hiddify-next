import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/proxies/notifier/notifier.dart';
import 'package:hiddify/features/proxies/notifier/proxies_delay_notifier.dart';
import 'package:hiddify/features/proxies/widgets/widgets.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// TODO: rewrite, bugs with scroll
class ProxiesPage extends HookConsumerWidget with PresLogger {
  const ProxiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final notifier = ref.watch(proxiesNotifierProvider.notifier);
    final asyncProxies = ref.watch(proxiesNotifierProvider);
    final proxies = asyncProxies.asData?.value ?? [];
    final delays = ref.watch(proxiesDelayNotifierProvider);

    final selectActiveProxyMutation = useMutation(
      initialOnFailure: (error) =>
          CustomToast.error(t.presentError(error)).show(context),
    );

    final tabController = useTabController(
      initialLength: proxies.length,
      keys: [proxies.length],
    );

    switch (asyncProxies) {
      case AsyncData(value: final proxies):
        if (proxies.isEmpty) {
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

        final tabs = [
          for (final groupWithProxies in proxies)
            Tab(
              child: Text(
                groupWithProxies.group.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ),
            )
        ];

        final tabViews = [
          for (final groupWithProxies in proxies)
            SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                builder: (BuildContext context) {
                  return CustomScrollView(
                    key: PageStorageKey<String>(
                      groupWithProxies.group.name,
                    ),
                    slivers: <Widget>[
                      SliverList.builder(
                        itemBuilder: (_, index) {
                          final proxy = groupWithProxies.proxies[index];
                          return ProxyTile(
                            proxy,
                            selected: groupWithProxies.group.now == proxy.name,
                            delay: delays[proxy.name],
                            onSelect: () async {
                              if (selectActiveProxyMutation
                                  .state.isInProgress) {
                                return;
                              }
                              selectActiveProxyMutation.setFuture(
                                notifier.changeProxy(
                                  groupWithProxies.group.name,
                                  proxy.name,
                                ),
                              );
                            },
                          );
                        },
                        itemCount: groupWithProxies.proxies.length,
                      ),
                    ],
                  );
                },
              ),
            ),
        ];

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                NestedTabAppBar(
                  title: Text(t.proxies.pageTitle.titleCase),
                  forceElevated: innerBoxIsScrolled,
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
                  bottom: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    tabs: tabs,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: tabViews,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async =>
                // TODO: improve
                ref.read(proxiesDelayNotifierProvider.notifier).testDelay(
                      proxies[tabController.index].proxies.map((e) => e.name),
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
                t.presentError(error),
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
