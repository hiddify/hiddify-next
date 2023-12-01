import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/services/platform_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
FilesEditorService filesEditorService(FilesEditorServiceRef ref) =>
    FilesEditorService(ref.watch(platformServicesProvider));

@Riverpod(keepAlive: true)
PlatformServices platformServices(PlatformServicesRef ref) =>
    PlatformServices();
