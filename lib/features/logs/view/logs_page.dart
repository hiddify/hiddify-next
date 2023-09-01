import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/logs/notifier/notifier.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:tint/tint.dart';

class LogsPage extends HookConsumerWidget with PresLogger {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncState = ref.watch(logsNotifierProvider);
    final notifier = ref.watch(logsNotifierProvider.notifier);

    final debug = ref.watch(debugModeProvider);
    final filesEditor = ref.watch(filesEditorServiceProvider);

    final List<PopupMenuEntry> popupButtons = debug || PlatformUtils.isDesktop
        ? [
            PopupMenuItem(
              child: Text(t.logs.shareCoreLogs.sentenceCase),
              onTap: () async {
                await UriUtils.tryShareOrLaunchFile(
                  Uri.parse(filesEditor.coreLogsPath),
                  fileOrDir: filesEditor.logsDir.uri,
                );
              },
            ),
            PopupMenuItem(
              child: Text(t.logs.shareAppLogs.sentenceCase),
              onTap: () async {
                await UriUtils.tryShareOrLaunchFile(
                  Uri.parse(filesEditor.appLogsPath),
                  fileOrDir: filesEditor.logsDir.uri,
                );
              },
            ),
          ]
        : [];

    switch (asyncState) {
      case AsyncData(value: final state):
        return Scaffold(
          appBar: AppBar(
            // TODO: fix height
            toolbarHeight: 90,
            title: Text(t.logs.pageTitle.titleCase),
            actions: [
              if (popupButtons.isNotEmpty)
                PopupMenuButton(
                  itemBuilder: (context) {
                    return popupButtons;
                  },
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(36),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        onChanged: notifier.filterMessage,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: t.logs.filterHint.sentenceCase,
                        ),
                      ),
                    ),
                    const Gap(16),
                    DropdownButton<Option<LogLevel>>(
                      value: optionOf(state.levelFilter),
                      onChanged: (v) {
                        if (v == null) return;
                        notifier.filterLevel(v.toNullable());
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      borderRadius: BorderRadius.circular(4),
                      items: [
                        DropdownMenuItem(
                          value: none(),
                          child: Text(t.logs.allLevelsFilter.sentenceCase),
                        ),
                        ...LogLevel.values.takeFirst(3).map(
                              (e) => DropdownMenuItem(
                                value: some(e),
                                child: Text(e.name.sentenceCase),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: state.logs.length,
            reverse: true,
            itemBuilder: (context, index) {
              final log = state.logs[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    subtitle: Text(log.strip()),
                  ),
                  if (index != 0)
                    const Divider(
                      indent: 16,
                      endIndent: 16,
                      height: 4,
                    ),
                ],
              );
            },
          ),
        );

      case AsyncError(:final error):
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.logs.pageTitle.titleCase),
              ),
              SliverErrorBodyPlaceholder(t.printError(error)),
            ],
          ),
        );

      case AsyncLoading():
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.logs.pageTitle.titleCase),
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
