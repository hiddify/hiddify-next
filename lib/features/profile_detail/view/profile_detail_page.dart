import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/confirmation_dialogs.dart';
import 'package:hiddify/features/profile_detail/notifier/notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// TODO: test and improve
// TODO: prevent popping screen when busy
class ProfileDetailPage extends HookConsumerWidget with PresLogger {
  const ProfileDetailPage(
    this.id, {
    super.key,
    this.url,
    this.name,
  });

  final String id;
  final String? url;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        profileDetailNotifierProvider(id, url: url, profileName: name);
    final t = ref.watch(translationsProvider);
    final asyncState = ref.watch(provider);
    final notifier = ref.watch(provider.notifier);

    final themeData = Theme.of(context);

    ref.listen(
      provider.select((data) => data.whenData((value) => value.save)),
      (_, asyncSave) {
        if (asyncSave case AsyncData(value: final save)) {
          switch (save) {
            case MutationFailure(:final failure):
              CustomToast.error(t.printError(failure)).show(context);
            case MutationSuccess():
              CustomToast.success(t.profile.save.successMsg.sentenceCase)
                  .show(context);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  if (context.mounted) context.pop();
                },
              );
          }
        }
      },
    );

    ref.listen(
      provider.select((data) => data.whenData((value) => value.delete)),
      (_, asyncSave) {
        if (asyncSave case AsyncData(value: final delete)) {
          switch (delete) {
            case MutationFailure(:final failure):
              CustomToast.error(t.printError(failure)).show(context);
            case MutationSuccess():
              CustomToast.success(t.profile.delete.successMsg.sentenceCase)
                  .show(context);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  if (context.mounted) context.pop();
                },
              );
          }
        }
      },
    );

    switch (asyncState) {
      case AsyncData(value: final state):
        return Stack(
          children: [
            Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(t.profile.detailsPageTitle.titleCase),
                  ),
                  const SliverGap(8),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: Form(
                      autovalidateMode: state.showErrorMessages
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const Gap(8),
                            CustomTextFormField(
                              initialValue: state.profile.name,
                              onChanged: (value) =>
                                  notifier.setField(name: value),
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? t.profile.detailsForm.emptyNameMsg
                                  : null,
                              label: t.profile.detailsForm.nameHint.titleCase,
                            ),
                            const Gap(16),
                            CustomTextFormField(
                              initialValue: state.profile.url,
                              onChanged: (value) =>
                                  notifier.setField(url: value),
                              validator: (value) =>
                                  (value != null && !isUrl(value))
                                      ? t.profile.detailsForm.invalidUrlMsg
                                      : null,
                              label:
                                  t.profile.detailsForm.urlHint.toUpperCase(),
                            ),
                          ],
                        ),
                      ),
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
                              if (state.isEditing)
                                FilledButton(
                                  onPressed: () async {
                                    final deleteConfirmed =
                                        await showConfirmationDialog(
                                      context,
                                      title:
                                          t.profile.delete.buttonTxt.titleCase,
                                      message: t.profile.delete.confirmationMsg
                                          .sentenceCase,
                                    );
                                    if (deleteConfirmed) {
                                      await notifier.delete();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                      themeData.colorScheme.errorContainer,
                                    ),
                                  ),
                                  child: Text(
                                    t.profile.delete.buttonTxt.titleCase,
                                    style: TextStyle(
                                      color: themeData
                                          .colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              OutlinedButton(
                                onPressed: notifier.save,
                                child:
                                    Text(t.profile.save.buttonText.titleCase),
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
            if (state.isBusy)
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

      // TODO: handle loading and error states
      default:
        return const Scaffold();
    }
  }
}
