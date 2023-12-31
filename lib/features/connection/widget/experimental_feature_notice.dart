import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'experimental_feature_notice.g.dart';

@riverpod
class DisableExperimentalFeatureNotice
    extends _$DisableExperimentalFeatureNotice {
  static const _key = "disable_experimental_feature_notice";

  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).requireValue.getBool(_key) ??
        false;
  }

  Future<void> change(bool pref) async {
    state = pref;
    await ref.read(sharedPreferencesProvider).requireValue.setBool(_key, pref);
  }
}

class ExperimentalFeatureNoticeDialog extends HookConsumerWidget {
  const ExperimentalFeatureNoticeDialog({super.key});

  Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final shouldDisable =
        useState(ref.read(disableExperimentalFeatureNoticeProvider));

    return PopScope(
      onPopInvoked: (didPop) async {
        await ref
            .read(disableExperimentalFeatureNoticeProvider.notifier)
            .change(shouldDisable.value);
      },
      child: AlertDialog(
        title: Text(t.home.connection.experimentalNotice),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 468,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.home.connection.experimentalNoticeMsg),
                CheckboxListTile(
                  value: shouldDisable.value,
                  title: Text(t.home.connection.disableExperimentalNotice),
                  onChanged: (value) => shouldDisable.value = value ?? false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.of(context).maybePop(false);
              if (context.mounted) const ConfigOptionsRoute().push(context);
            },
            child: Text(t.settings.config.pageTitle),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}
