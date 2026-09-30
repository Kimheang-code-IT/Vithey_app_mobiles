import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';

/// Opens the official ACLEDA mobile app. If it is not installed, falls back
/// to the store listing — no in-app payment screen.
class AcledaMobileLauncher {
  static const androidPackage = 'com.domain.acledabankqr';
  static const appUri = 'ACLEDAmobile://';
  static const playStoreWeb =
      'https://play.google.com/store/apps/details?id=$androidPackage';
  static const appStoreWeb =
      'https://apps.apple.com/us/app/acleda-unity-toanchet/id1196285236';

  static Future<void> open() async {
    try {
      if (await _tryLaunch(Uri.parse(appUri))) return;

      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = Uri.parse(
          'intent://#Intent;scheme=ACLEDAmobile;package=$androidPackage;end',
        );
        if (await _tryLaunch(intent)) return;
        if (await _tryLaunch(Uri.parse('market://details?id=$androidPackage'))) {
          return;
        }
        if (await _tryLaunch(Uri.parse(playStoreWeb))) return;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (await _tryLaunch(Uri.parse(appStoreWeb))) return;
      } else if (await _tryLaunch(Uri.parse(playStoreWeb))) {
        return;
      }

      Get.snackbar(AppStrings.appName, 'Could not open ACLEDA mobile');
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open ACLEDA mobile');
    }
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
