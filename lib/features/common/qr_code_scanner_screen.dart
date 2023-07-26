import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerScreen extends HookConsumerWidget with PresLogger {
  const QRCodeScannerScreen({super.key});

  Future<String?> open(BuildContext context) async {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const QRCodeScannerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(
      () => MobileScannerController(
        detectionTimeoutMs: 500,
        formats: [BarcodeFormat.qrCode],
      ),
    );

    useEffect(() => controller.dispose, []);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Colors.white,
              size: 32,
            ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final data = capture.barcodes.first;
          if (context.mounted && data.type == BarcodeType.url) {
            loggy.debug('captured raw: [${data.rawValue}]');
            loggy.debug('captured url: [${data.url?.url}]');
            Navigator.of(context, rootNavigator: true).pop(data.url?.url);
          }
        },
      ),
    );
  }
}
