import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// TODO: rewrite
class WindowManagerService with WindowListener {
  Future<void> init() async {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(868, 768),
      minimumSize: Size(868, 648),
      center: true,
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }
}
