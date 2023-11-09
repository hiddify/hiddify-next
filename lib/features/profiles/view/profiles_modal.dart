import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/features/common/profile_tile.dart';
import 'package:hiddify/features/profiles/notifier/notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilesModal extends HookConsumerWidget {
  const ProfilesModal({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncProfiles = ref.watch(profilesNotifierProvider);

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            switch (asyncProfiles) {
              AsyncData(value: final profiles) => SliverList.builder(
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return ProfileTile(profile: profile);
                  },
                  itemCount: profiles.length,
                ),
              AsyncError(:final error) => SliverErrorBodyPlaceholder(
                  t.presentShortError(error),
                ),
              AsyncLoading() => const SliverLoadingBodyPlaceholder(),
              _ => const SliverToBoxAdapter(),
            },
            const SliverGap(48),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    const AddProfileRoute().push(context);
                  },
                  icon: const Icon(Icons.add),
                  label: Text(t.profile.add.shortBtnTxt),
                ),
                FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ProfilesSortModal();
                      },
                    );
                  },
                  icon: const Icon(Icons.sort),
                  label: Text(t.general.sort),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilesSortModal extends HookConsumerWidget {
  const ProfilesSortModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return AlertDialog(
      title: Text(t.general.sortBy),
      content: Consumer(
        builder: (context, ref, child) {
          final sort = ref.watch(profilesSortNotifierProvider);
          return SingleChildScrollView(
            child: Column(
              children: [
                ...ProfilesSort.values.map(
                  (e) {
                    final selected = sort.by == e;
                    final double arrowTurn =
                        sort.mode == SortMode.ascending ? 0 : 0.5;

                    return ListTile(
                      title: Text(e.present(t)),
                      onTap: () {
                        if (selected) {
                          ref
                              .read(profilesSortNotifierProvider.notifier)
                              .toggleMode();
                        } else {
                          ref
                              .read(profilesSortNotifierProvider.notifier)
                              .changeSort(e);
                        }
                      },
                      selected: selected,
                      leading: Icon(e.icon),
                      trailing: selected
                          ? IconButton(
                              onPressed: () {
                                ref
                                    .read(profilesSortNotifierProvider.notifier)
                                    .toggleMode();
                              },
                              icon: AnimatedRotation(
                                turns: arrowTurn,
                                duration: const Duration(milliseconds: 100),
                                child: Icon(
                                  Icons.arrow_upward,
                                  semanticLabel: sort.mode.name,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
