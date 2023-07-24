import 'package:flutter/material.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/profiles/notifier/notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilesModal extends HookConsumerWidget {
  const ProfilesModal({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfiles = ref.watch(profilesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
            // TODO: handle loading and error
            _ => const SliverToBoxAdapter(),
          },
        ],
      ),
    );
  }
}
