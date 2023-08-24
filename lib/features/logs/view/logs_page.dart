import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/misc_prefs.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/logs/notifier/notifier.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tint/tint.dart';
import 'package:url_launcher/url_launcher.dart';

class LogsPage extends HookConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncState = ref.watch(logsNotifierProvider);
    final notifier = ref.watch(logsNotifierProvider.notifier);

    final debug = ref.watch(debugModeProvider);

    final List<PopupMenuEntry> popupButtons = debug || PlatformUtils.isDesktop
        ? [
            PopupMenuItem(
              child: Text(t.logs.shareCoreLogs.sentenceCase),
              onTap: () async {
                if (Platform.isWindows || Platform.isLinux) {
                  await launchUrl(
                    ref.read(filesEditorServiceProvider).logsDir.uri,
                  );
                } else {
                  final file = XFile(
                    ref.read(filesEditorServiceProvider).coreLogsPath,
                    mimeType: "text/plain",
                  );
                  await Share.shareXFiles([file]);
                }
              },
            ),
            PopupMenuItem(
              child: Text(t.logs.shareAppLogs.sentenceCase),
              onTap: () async {
                if (Platform.isWindows || Platform.isLinux) {
                  await launchUrl(
                    ref.read(filesEditorServiceProvider).logsDir.uri,
                  );
                } else {
                  final file = XFile(
                    ref.read(filesEditorServiceProvider).appLogsPath,
                    mimeType: "text/plain",
                  );
                  await Share.shareXFiles([file]);
                }
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
              SliverErrorBodyPlaceholder(t.presentError(error)),
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
