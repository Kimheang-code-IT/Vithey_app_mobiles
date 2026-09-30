import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';

enum AppLanguageOption { en, km }

class SelectLanguageController extends GetxController {
  SelectLanguageController(
    this._localStorage, {
    this.fromOnboarding = false,
  });

  final LocalStorageService _localStorage;
  final bool fromOnboarding;

  final selected = AppLanguageOption.en.obs;
  final contentOpacity = 1.0.obs;
  final isBusy = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
    if (fromOnboarding) {
      contentOpacity.value = 0;
      _enterFromOnboarding();
    }
  }

  Future<void> _loadSaved() async {
    final code = await _localStorage.readLanguage();
    if (isClosed) return;
    selected.value =
        code == 'km' ? AppLanguageOption.km : AppLanguageOption.en;
  }

  Future<void> _enterFromOnboarding() async {
    await IntroMorph.run(IntroMorph.duration, (t) {
      if (isClosed) return;
      contentOpacity.value = t;
    });
    if (!isClosed) contentOpacity.value = 1;
  }

  void select(AppLanguageOption option) {
    if (isBusy.value) return;
    selected.value = option;
  }

  Future<void> next() => _goNext(selected.value);

  Future<void> _goNext(AppLanguageOption option) async {
    if (isBusy.value) return;
    isBusy.value = true;

    final code = switch (option) {
      AppLanguageOption.en => 'en',
      AppLanguageOption.km => 'km',
    };

    try {
      await _localStorage.saveLanguage(code);
      await _localStorage.setLanguageSelected(true);
      final onboardingDone = await _localStorage.isOnboardingCompleted();
      if (onboardingDone) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
    } catch (_) {}

    // Navigate immediately — morph runs on Onboarding enter.
    IntroMorph.fromLanguage = true;
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
