import 'package:hiddify/services/connectivity/connectivity.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/services/notification/notification.dart';
import 'package:hiddify/services/runtime_details_service.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) =>
    NotificationService();

@Riverpod(keepAlive: true)
FilesEditorService filesEditorService(FilesEditorServiceRef ref) =>
    FilesEditorService();

@Riverpod(keepAlive: true)
RuntimeDetailsService runtimeDetailsService(RuntimeDetailsServiceRef ref) =>
    RuntimeDetailsService();

@Riverpod(keepAlive: true)
SingboxService singboxService(SingboxServiceRef ref) => SingboxService();

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(ConnectivityServiceRef ref) =>
    ConnectivityService(
      ref.watch(singboxServiceProvider),
      ref.watch(notificationServiceProvider),
    );
