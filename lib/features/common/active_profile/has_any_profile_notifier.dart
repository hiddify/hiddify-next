import 'package:hiddify/data/data_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'has_any_profile_notifier.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> hasAnyProfile(
  HasAnyProfileRef ref,
) {
  return ref
      .watch(profilesRepositoryProvider)
      .watchHasAnyProfile()
      .map((event) => event.getOrElse((l) => throw l));
}
