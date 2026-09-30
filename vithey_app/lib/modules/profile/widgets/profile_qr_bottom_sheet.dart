import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:get/get.dart';

Future<void> showProfileQrBottomSheet({
  required BuildContext context,
  required String userId,
  required String userName,
}) {
  return showEditProfileSheet<void>(
    context: context,
    title: 'QR Code',
    builder: (sheetContext) {
      return _ProfileQrSheetBody(
        userId: userId,
        userName: userName,
      );
    },
  );
}

class _ProfileQrSheetBody extends StatelessWidget {
  const _ProfileQrSheetBody({
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  static const _buttonGap = 16.0;

  void _onScanQrCode(BuildContext context) {
    Navigator.of(context).pop();
    Get.toNamed(AppRoutes.scanQr);
  }

  void _onShareQrCode() {
    shareProfileLink(userId, userName);
  }

  @override
  Widget build(BuildContext context) {
    final qrSize = MediaQuery.sizeOf(context).width * 0.62;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            child: Image.asset(
              AppAssets.profileQrCode,
              width: qrSize,
              height: qrSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                label: 'Scan QR Code',
                onPressed: () => _onScanQrCode(context),
              ),
              const SizedBox(width: _buttonGap),
              CustomButton(
                label: 'Share QR Code',
                variant: CustomButtonVariant.outline,
                onPressed: _onShareQrCode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
