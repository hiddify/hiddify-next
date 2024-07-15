import 'dart:async';
import 'dart:developer';

import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta_meta.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
// import 'package:permission_handler/permission_handler.dart';

const permissions = [Permissions.CAMERA];
const permissionGroup = [PermissionGroup.Camera];

class QRCodeScannerScreen extends StatefulHookConsumerWidget {
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
  ConsumerState<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends ConsumerState<QRCodeScannerScreen> with WidgetsBindingObserver, PresLogger {
  final MobileScannerController controller = MobileScannerController(
    detectionTimeoutMs: 500,
    autoStart: false,
  );
  bool started = false;

  // late FlutterEasyPermission _easyPermission;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();

    // _easyPermission = FlutterEasyPermission()
    //   ..addPermissionCallback(onGranted: (requestCode, androidPerms, iosPerm) {
    //     debugPrint("android:$androidPerms");
    //     debugPrint("iOS:$iosPerm");
    //     startQrScannerIfPermissionGranted();
    //   }, onDenied: (requestCode, androidPerms, iosPerm, isPermanent) {
    //     if (isPermanent) {
    //       FlutterEasyPermission.showAppSettingsDialog(title: "Camera");
    //     } else {
    //       debugPrint("android:$androidPerms");
    //       debugPrint("iOS:$iosPerm");
    //     }
    //   }, onSettingsReturned: () {
    //     startQrScannerIfPermissionGranted();
    //   });
  }

  Future<bool> _requestCameraPermission() async {
    final hasPermission = await FlutterEasyPermission.has(
      perms: permissions,
      permsGroup: permissionGroup,
    );

    if (hasPermission) return true;

    final completer = Completer<bool>();

    void permissionCallback(int requestCode, List<Permissions> ?perms, PermissionGroup ?perm) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    }

    void permissionDeniedCallback(int requestCode, List<Permissions> ?perms, PermissionGroup ?perm, bool isPermanent) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    FlutterEasyPermission().addPermissionCallback(
      onGranted: permissionCallback,
      onDenied: permissionDeniedCallback,
    );

    FlutterEasyPermission.request(
      perms: permissions,
      permsGroup: permissionGroup,
      rationale: "Camera permission is required to scan QR codes.",
    );

    return completer.future;
  }

  Future<void> _initializeScanner() async {
    final hasPermission = await _requestCameraPermission();
    if (hasPermission) {
      _startScanner();
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _scanImageForQR(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? result = await controller.analyzeImage(image.path);

      if (result != null && result.barcodes.isNotEmpty) {
        final List<Barcode> barcodes = result.barcodes;
        final String? qrCode = barcodes.first.rawValue;
        if (qrCode != null && context.mounted) {
          Navigator.of(ctx, rootNavigator: true).pop(qrCode);
        }
      } else {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text("No QR Found")),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    // _easyPermission.dispose();
    FlutterEasyPermission().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Checking app cycle so that when user returns from settings, need to recheck for permissions
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndStartScanner();
    }
  }

  Future<void> _checkPermissionAndStartScanner() async {
    final hasPermission = await FlutterEasyPermission.has(
      perms: permissions,
      permsGroup: permissionGroup,
    );

    if (hasPermission) {
      _startScanner();
    } else {
      setState(() {});
    }
  }

  Future<void> _startScanner() async {
    if(controller.value.isInitialized && controller.value.isRunning) {
      return;
    }
    await controller.start().whenComplete(() {
      setState(() {
        started = true;
      });
    }).catchError((error) {
      log("CAM ERROR: $error");
      loggy.warning("Error starting scanner: $error");
    });
  }

  Future<void> startQrScannerIfPermissionIsGranted() async {
    final hasPermission = await FlutterEasyPermission.has(
      perms: permissions,
      permsGroup: permissionGroup,
    );
    if (hasPermission) {
      _startScanner();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    FlutterEasyPermission.showAppSettingsDialog(
      title: "Camera Access Required",
      rationale: "Permission to camera to scan QR Code",
      positiveButtonText: "Settings",
      negativeButtonText: "Cancel",
    );
  }

  @override
  Widget build(BuildContext context) {
    final Translations t = ref.watch(translationsProvider);

    // startQrScannerIfPermissionGranted();

    return FutureBuilder(
      future: FlutterEasyPermission.has(
        perms: permissions,
        permsGroup: permissionGroup,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return _buildScannerUI(context, t);
        } else {
          return _buildPermissionDeniedUI(context, t);
        }
      },
    );
  }

  Widget _buildScannerUI(BuildContext context, Translations t) {
    final size = MediaQuery.sizeOf(context);
    final overlaySize = (size.shortestSide - 12).coerceAtMost(248);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Colors.white,
          size: 32,
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, MobileScannerState state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }
              switch (state.torchState) {
                case TorchState.off:
                  return IconButton(
                    icon: const Icon(
                      FluentIcons.flash_off_24_regular,
                      color: Colors.grey,
                    ),
                    tooltip: t.profile.add.qrScanner.torchSemanticLabel,
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.on:
                  return IconButton(
                    icon: const Icon(
                      FluentIcons.flash_24_regular,
                      color: Colors.yellow,
                    ),
                    tooltip: t.profile.add.qrScanner.torchSemanticLabel,
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.auto:
                  return IconButton(
                    icon: const Icon(
                      FluentIcons.flash_auto_24_regular,
                      color: Colors.grey,
                    ),
                    tooltip: t.profile.add.qrScanner.torchSemanticLabel,
                    onPressed: () async {
                      await controller.toggleTorch();
                    },
                  );
                case TorchState.unavailable:
                  return const Icon(
                    Icons.no_flash,
                  );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(FluentIcons.camera_switch_24_regular),
              tooltip: t.profile.add.qrScanner.facingSemanticLabel,
              onPressed: () => controller.switchCamera(),
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.image_24_regular),
            tooltip: 'Pick an Image',
            onPressed: () => _scanImageForQR(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final rawData = capture.barcodes.first.rawValue;
              loggy.debug('captured raw: [$rawData]');
              if (rawData != null) {
                final uri = Uri.tryParse(rawData);
                if (context.mounted && uri != null) {
                  loggy.debug('captured url: [$uri]');
                  Navigator.of(context, rootNavigator: true).pop(uri.toString());
                }
              } else {
                loggy.warning("unable to capture");
              }
            },
            errorBuilder: (_, error, __) {
              final message = switch (error.errorCode) {
                MobileScannerErrorCode.permissionDenied => t.profile.add.qrScanner.permissionDeniedError,
                _ => t.profile.add.qrScanner.unexpectedError,
              };

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Icon(
                        FluentIcons.error_circle_24_regular,
                        color: Colors.white,
                      ),
                    ),
                    Text(message),
                    Text(error.errorDetails?.message ?? ''),
                  ],
                ),
              );
            },
          ),
          if (started)
            CustomPaint(
              painter: ScannerOverlay(
                Rect.fromCenter(
                  center: size.center(Offset.zero),
                  width: overlaySize,
                  height: overlaySize,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedUI(BuildContext context, Translations t) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Colors.white,
          size: 32,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.profile.add.qrScanner.permissionDeniedError),
            const SizedBox(height: 16),
            if(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
              ElevatedButton(
                onPressed: _showPermissionDialog,
                child: const Text("Settings"),
              )
            else
              OutlinedButton.icon(
                icon: const Icon(FluentIcons.image_24_regular),
                onPressed: () => _scanImageForQR(context),
                label: const Text('Pick an Image'),
              ),
          ],
        ),
      ),
    );
  }

}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;
  final double borderRadius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}