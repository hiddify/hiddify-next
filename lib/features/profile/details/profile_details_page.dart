import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/widget/adaptive_icon.dart';
import 'package:hiddify/features/common/confirmation_dialogs.dart';
import 'package:hiddify/features/profile/details/profile_details_notifier.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:humanizer/humanizer.dart';

class ProfileDetailsPage extends HookConsumerWidget with PresLogger {
  const ProfileDetailsPage(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final provider = profileDetailsNotifierProvider(id);
    final notifier = ref.watch(provider.notifier);

    ref.listen(
      provider.selectAsync((data) => data.save),
      (_, next) async {
        switch (await next) {
          case AsyncData():
            CustomToast.success(t.profile.save.successMsg).show(context);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                if (context.mounted) context.pop();
              },
            );
          case AsyncError(:final error):
            final String action;
            if (ref.read(provider) case AsyncData(value: final data)
                when data.isEditing) {
              action = t.profile.save.failureMsg;
            } else {
              action = t.profile.add.failureMsg;
            }
            CustomAlertDialog.fromErr(t.presentError(error, action: action))
                .show(context);
        }
      },
    );

    ref.listen(
      provider.selectAsync((data) => data.update),
      (_, next) async {
        switch (await next) {
          case AsyncData():
            CustomToast.success(t.profile.update.successMsg).show(context);
          case AsyncError(:final error):
            CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
      },
    );

    ref.listen(
      provider.selectAsync((data) => data.delete),
      (_, next) async {
        switch (await next) {
          case AsyncData():
            CustomToast.success(t.profile.delete.successMsg).show(context);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                if (context.mounted) context.pop();
              },
            );
          case AsyncError(:final error):
            CustomToast.error(t.presentShortError(error)).show(context);
        }
      },
    );

    switch (ref.watch(provider)) {
      case AsyncData(value: final state):
        final showLoadingOverlay = state.isBusy ||
            state.save is MutationSuccess ||
            state.delete is MutationSuccess;

        return Stack(
          children: [
            Scaffold(
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(t.profile.detailsPageTitle),
                      pinned: true,
                      actions: [
                        if (state.isEditing)
                          PopupMenuButton(
                            icon: Icon(AdaptiveIcon(context).more),
                            itemBuilder: (context) {
                              return [
                                if (state.profile case RemoteProfileEntity())
                                  PopupMenuItem(
                                    child: Text(t.profile.update.buttonTxt),
                                    onTap: () async {
                                      await notifier.updateProfile();
                                    },
                                  ),
                                PopupMenuItem(
                                  child: Text(t.profile.delete.buttonTxt),
                                  onTap: () async {
                                    final deleteConfirmed =
                                        await showConfirmationDialog(
                                      context,
                                      title: t.profile.delete.buttonTxt,
                                      message: t.profile.delete.confirmationMsg,
                                    );
                                    if (deleteConfirmed) {
                                      await notifier.delete();
                                    }
                                  },
                                ),
                              ];
                            },
                          ),
                      ],
                    ),
                    Form(
                      autovalidateMode: state.showErrorMessages
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: SliverList.list(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: CustomTextFormField(
                              initialValue: state.profile.name,
                              onChanged: (value) =>
                                  notifier.setField(name: value),
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? t.profile.detailsForm.emptyNameMsg
                                  : null,
                              label: t.profile.detailsForm.nameLabel,
                              hint: t.profile.detailsForm.nameHint,
                            ),
                          ),
                          if (state.profile
                              case RemoteProfileEntity(
                                :final url,
                                :final options
                              )) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: CustomTextFormField(
                                initialValue: url,
                                onChanged: (value) =>
                                    notifier.setField(url: value),
                                validator: (value) =>
                                    (value != null && !isUrl(value))
                                        ? t.profile.detailsForm.invalidUrlMsg
                                        : null,
                                label: t.profile.detailsForm.urlLabel,
                                hint: t.profile.detailsForm.urlHint,
                              ),
                            ),
                            ListTile(
                              title: Text(t.profile.detailsForm.updateInterval),
                              subtitle: Text(
                                options?.updateInterval.toApproximateTime(
                                      isRelativeToNow: false,
                                    ) ??
                                    t.general.toggle.disabled,
                              ),
                              leading:
                                  const Icon(FluentIcons.arrow_sync_24_regular),
                              onTap: () async {
                                final intervalInHours =
                                    await SettingsInputDialog(
                                  title: t.profile.detailsForm
                                      .updateIntervalDialogTitle,
                                  initialValue: options?.updateInterval.inHours,
                                  optionalAction: (
                                    t.general.state.disable,
                                    () => notifier.setField(
                                          updateInterval: none(),
                                        ),
                                  ),
                                  validator: isPort,
                                  mapTo: int.tryParse,
                                  digitsOnly: true,
                                ).show(context);
                                if (intervalInHours == null) return;
                                notifier.setField(
                                  updateInterval: optionOf(intervalInHours),
                                );
                              },
                            ),
                          ],
                          if (state.isEditing)
                            ListTile(
                              title: Text(t.profile.detailsForm.lastUpdate),
                              subtitle: Text(state.profile.lastUpdate.format()),
                              dense: true,
                            ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            OverflowBar(
                              spacing: 12,
                              overflowAlignment: OverflowBarAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: context.pop,
                                  child: Text(
                                    MaterialLocalizations.of(context)
                                        .cancelButtonLabel,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: notifier.save,
                                  child: Text(t.profile.save.buttonText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showLoadingOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );

      case AsyncError(:final error):
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(t.profile.detailsPageTitle),
                pinned: true,
              ),
              SliverErrorBodyPlaceholder(t.presentShortError(error)),
            ],
          ),
        );

      default:
        return const Scaffold();
    }
  }
}
