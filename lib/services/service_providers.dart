import 'package:hiddify/data/data_providers.dart';
import 'package:hiddify/services/cron_service.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/services/platform_settings.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
FilesEditorService filesEditorService(FilesEditorServiceRef ref) =>
    FilesEditorService();

@Riverpod(keepAlive: true)
SingboxService singboxService(SingboxServiceRef ref) => SingboxService();

@riverpod
PlatformSettings platformSettings(PlatformSettingsRef ref) =>
    PlatformSettings();

@Riverpod(keepAlive: true)
CronService cronService(CronServiceRef ref) {
  final service = CronService(ref.watch(sharedPreferencesProvider));
  ref.onDispose(() => service.stopScheduler());
  return service;
}
