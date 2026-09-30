import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/modules/profile/widgets/qr_scan_corner_frame.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Live camera QR scanner — matches `Scan QR.png`.
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _handled = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() => _torchOn = _controller.torchEnabled);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    _handled = true;
    unawaited(_controller.stop());
    Get.back<void>();
    _handlePayload(raw);
  }

  void _handlePayload(String raw) {
    final userId = _parseUserId(raw);
    if (userId != null) {
      openUserProfile(userId);
      return;
    }
    Get.snackbar(
      'QR Code',
      raw,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  String? _parseUserId(String raw) {
    final trimmed = raw.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmed) &&
        (trimmed.startsWith('mock-') ||
            trimmed.startsWith('author-') ||
            trimmed.startsWith('user-'))) {
      return trimmed;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'profile') {
        return uri.pathSegments[1];
      }
      final profileIdx = uri.pathSegments.indexOf('profile');
      if (profileIdx >= 0 && profileIdx + 1 < uri.pathSegments.length) {
        return uri.pathSegments[profileIdx + 1];
      }
      final userId = uri.queryParameters['userId'] ?? uri.queryParameters['id'];
      if (userId != null && userId.isNotEmpty) return userId;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanSize = size.width * 0.72;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return ColoredBox(
                color: const Color(0xFF1C1C1E),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error.errorCode == MobileScannerErrorCode.permissionDenied
                          ? 'Camera permission is required to scan QR codes.'
                          : 'Unable to open the camera.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 4,
                  left: 4,
                  child: IconButton(
                    onPressed: () => Get.back<void>(),
                    icon: const VitheyIcon(LucideIcons.arrowLeft, color: Colors.white),
                    tooltip: 'Back',
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Scan QR Code',
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      QrScanCornerFrame(size: scanSize),
                      const SizedBox(height: 56),
                      _TorchButton(
                        enabled: _torchOn,
                        onPressed: _toggleTorch,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: VitheyIcon(
            enabled ? LucideIcons.flashlight : LucideIcons.flashlight,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
