import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/google_auth_service.dart';
import 'package:aub_connect_app/modules/auth/intro_ribbon_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';
import 'package:intl/intl.dart';

enum AuthIntent { signIn, register, changeEmail }

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final loginFormKey = GlobalKey<FormState>();
  final registerPart1FormKey = GlobalKey<FormState>();
  final registerPart2FormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isForgotPasswordLoading = false.obs;
  final forgotPasswordSuccess = false.obs;
  final errorMessage = ''.obs;
  final forgotPasswordError = ''.obs;
  final authIntent = AuthIntent.signIn.obs;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotPasswordEmailController = TextEditingController();

  /// Auth v2: 0 = Sign In, 1 = Sign Up (synced from intro ribbon).
  final authPageIndex = 0.obs;

  /// In-place Sign In → Forgot Password morph (stays on continuum).
  final showForgotPassword = false.obs;

  /// Sign Up only: 0 = Part 1 (credentials), 1 = Part 2 (profile).
  final registerStep = 0.obs;

  /// True while Part 1 ↔ Part 2 field slide is running.
  final isRegisterStepAnimating = false.obs;

  final isBusy = false.obs;

  DateTime? dateOfBirth;

  /// Keep Google UI visible; set ENABLE_GOOGLE_AUTH=true in .env when ready.
  bool get isGoogleAuthEnabled => Get.find<FeatureFlags>().enableGoogleAuth;

  @override
  void onInit() {
    super.onInit();
    final startOnSignUp =
        Get.currentRoute == AppRoutes.register || IntroMorph.startOnSignUp;
    authPageIndex.value = startOnSignUp ? 1 : 0;
  }

  void showSignIn() {
    if (isRegisterStepAnimating.value || authPageIndex.value == 0) return;
    clearError();
    registerStep.value = 0;
    showForgotPassword.value = false;
    if (Get.isRegistered<IntroRibbonController>()) {
      Get.find<IntroRibbonController>().showSignIn();
      return;
    }
    authPageIndex.value = 0;
  }

  void openForgotPassword() {
    FormErrorHost.clearAll();
    clearError();
    resetForgotPasswordState();
    final email = emailController.text.trim();
    if (email.isNotEmpty) {
      forgotPasswordEmailController.text = email;
    }
    showForgotPassword.value = true;
  }

  void closeForgotPassword() {
    FormErrorHost.clearAll();
    resetForgotPasswordState();
    showForgotPassword.value = false;
  }

  void showSignUp() {
    if (isRegisterStepAnimating.value || authPageIndex.value == 1) return;
    clearError();
    registerStep.value = 0;
    if (Get.isRegistered<IntroRibbonController>()) {
      Get.find<IntroRibbonController>().showSignUp();
      return;
    }
    authPageIndex.value = 1;
  }

  /// Leave Auth → slide back on the intro ribbon (or pop if stacked).
  Future<void> goBack() async {
    if (isBusy.value) return;
    if (showForgotPassword.value) {
      closeForgotPassword();
      return;
    }
    if (Get.isRegistered<IntroRibbonController>()) {
      await Get.find<IntroRibbonController>().authBack();
      return;
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  void clearError() {
    if (errorMessage.isNotEmpty) errorMessage.value = '';
  }

  String? confirmPasswordValidator(String? value) {
    return Validators.confirmPassword(value, passwordController.text);
  }

  Future<void> goToRegisterPart2() async {
    if (isRegisterStepAnimating.value || registerStep.value == 1) return;
    if (!await FormErrorHost.submit(registerPart1FormKey)) return;
    clearError();
    registerStep.value = 1;
  }

  void goToRegisterPart1() {
    if (isRegisterStepAnimating.value ||
        isLoading.value ||
        registerStep.value == 0) {
      return;
    }
    clearError();
    registerStep.value = 0;
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initial = dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    dateOfBirth = picked;
    dateOfBirthController.text = DateFormat('dd MMM yyyy').format(picked);
    clearError();
  }

  Future<void> login() async {
    if (!await FormErrorHost.submit(loginFormKey)) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await AuthNavigation.goAfterAuth();
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (registerStep.value != 1) return;
    if (!await FormErrorHost.submit(registerPart2FormKey)) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );
      await AuthNavigation.goAfterAuth(isNewUser: true);
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  /// Runs the real Google sign-in flow, then exchanges the Google ID token for
  /// a Vithey session via the backend.
  ///
  /// User cancellation returns cleanly to the login screen with no error.
  Future<void> continueWithGoogle({required AuthIntent intent}) async {
    if (isGoogleLoading.value) return;
    authIntent.value = intent;
    isGoogleLoading.value = true;
    clearError();
    try {
      await _authRepository.signInWithGoogle();
      await AuthNavigation.goAfterAuth(isNewUser: intent == AuthIntent.register);
    } on GoogleSignInCancelledException {
      // User dismissed the Google sheet — no error, stay on the auth screen.
    } on AuthServiceException catch (e) {
      errorMessage.value = e.message;
    } on GoogleAuthException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// Opens the real Google chooser and returns the selected account email for
  /// the Account → Edit "change email" affordance (no new auth session).
  Future<String?> beginGoogleEmailChange() async {
    authIntent.value = AuthIntent.changeEmail;
    clearError();
    try {
      return await _authRepository.googleEmailForAccountChange();
    } on GoogleAuthException catch (e) {
      errorMessage.value = e.message;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> requestPasswordReset() async {
    isForgotPasswordLoading.value = true;
    forgotPasswordError.value = '';
    try {
      await _authRepository.requestPasswordReset(
        email: forgotPasswordEmailController.text.trim(),
      );
      forgotPasswordSuccess.value = true;
    } on AuthServiceException catch (e) {
      forgotPasswordError.value = e.message;
    } catch (_) {
      forgotPasswordError.value = AppStrings.errorGeneric;
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  void resetForgotPasswordState() {
    forgotPasswordSuccess.value = false;
    forgotPasswordError.value = '';
    forgotPasswordEmailController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}
