import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  // App contact details shown on the About screen. Update in one place.
  static const contactPhone = '+855 96 222 333';
  static const contactEmail = 'support@vithey.app';
  static const contactWebsite = 'https://vithey.app';
  static const contactLocation = 'Phnom Penh, Cambodia';

  final version = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    isLoading.value = true;
    try {
      final info = await PackageInfo.fromPlatform();
      version.value = 'Version ${info.version} (${info.buildNumber})';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Vithey', 'Could not open link');
    }
  }

  void openWebsite() => openUrl(contactWebsite);
  void callPhone() => openUrl('tel:${contactPhone.replaceAll(' ', '')}');
  void sendEmail() => openUrl('mailto:$contactEmail');
}
