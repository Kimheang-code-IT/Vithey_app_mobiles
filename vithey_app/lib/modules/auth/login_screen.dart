import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/validators.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/widgets/oauth_button.dart';
import 'package:aub_connect_app/modules/auth/widgets/register_step_slider.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Full auth frame: ribbon wave + logo + form + back.
///
/// When [enableForgotMorph] is true (Sign In), Forgot Password morphs in-place:
/// form fades out → teal wave moves down → logo recenters → forgot form fades in.
///
/// When [omitFixedChrome] is true, wave + form still slide with the page; logo
/// and Back are owned by [IntroRibbonScreen] (logo slides in with Sign In, then
/// only moves vertically on Sign In ↔ Sign Up).
class AuthRibbonFrame extends StatefulWidget {
  const AuthRibbonFrame({
    super.key,
    required this.profile,
    required this.form,
    required this.onBack,
    this.enableForgotMorph = false,
    this.startOnForgot = false,
    this.omitFixedChrome = false,
    this.forgotMorphListenable,
  });

  final WaveRibbonProfile profile;
  final Widget form;
  final VoidCallback onBack;
  final bool enableForgotMorph;
  final bool startOnForgot;

  /// Hide local logo + Back; keep sliding wave + form (intro continuum).
  final bool omitFixedChrome;

  /// Shared forgot-password morph (0 = sign-in, 1 = forgot) for logo sync.
  final Animation<double>? forgotMorphListenable;

  @override
  State<AuthRibbonFrame> createState() => _AuthRibbonFrameState();
}

class _AuthRibbonFrameState extends State<AuthRibbonFrame>
    with SingleTickerProviderStateMixin {
  static const _morphDuration = Duration(milliseconds: 560);

  AnimationController? _ownedMorph;
  Worker? _forgotWorker;

  Animation<double> get _morph =>
      widget.forgotMorphListenable ?? _ownedMorph!;

  @override
  void initState() {
    super.initState();
    if (widget.forgotMorphListenable == null) {
      _ownedMorph = AnimationController(vsync: this, duration: _morphDuration);
      if (widget.startOnForgot) {
        _ownedMorph!.value = 1;
      }
      if (widget.enableForgotMorph && Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        if (auth.showForgotPassword.value || widget.startOnForgot) {
          _ownedMorph!.value = 1;
          auth.showForgotPassword.value = true;
        }
        _forgotWorker = ever<bool>(auth.showForgotPassword, (show) {
          if (!mounted || _ownedMorph == null) return;
          if (show) {
            FocusManager.instance.primaryFocus?.unfocus();
            _ownedMorph!.forward();
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
            _ownedMorph!.reverse();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _forgotWorker?.dispose();
    _ownedMorph?.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.enableForgotMorph &&
        Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().showForgotPassword.value) {
      Get.find<AuthController>().closeForgotPassword();
      return;
    }
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;
    final formWidth = screenW < 420 ? screenW : 420.0;

    return AnimatedBuilder(
      animation: _morph,
      builder: (context, _) {
        final t = _morph.value;
        final waveT = Curves.easeInOutCubic.transform(
          const Interval(0.12, 0.88).transform(t),
        );
        final activeProfile = widget.enableForgotMorph
            ? widget.profile.lerp(WaveRibbon.forgotPassword, waveT)
            : widget.profile;

        final signOut = Curves.easeIn.transform(
          const Interval(0.0, 0.32).transform(t),
        );
        final forgotIn = Curves.easeOut.transform(
          const Interval(0.52, 1.0).transform(t),
        );
        final signOpacity =
            widget.enableForgotMorph ? (1.0 - signOut).clamp(0.0, 1.0) : 1.0;
        final forgotOpacity =
            widget.enableForgotMorph ? forgotIn.clamp(0.0, 1.0) : 0.0;

        final tealBandH = screenH *
            OnboardingBackground.tealBandHeightFraction(activeProfile);

        final formStack = Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: formWidth,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (signOpacity > 0.01)
                  IgnorePointer(
                    ignoring: signOpacity < 0.05,
                    child: Opacity(
                      opacity: signOpacity,
                      child: widget.form,
                    ),
                  ),
                if (widget.enableForgotMorph && forgotOpacity > 0.01)
                  IgnorePointer(
                    ignoring: forgotOpacity < 0.05,
                    child: Opacity(
                      opacity: forgotOpacity,
                      child: const AuthForgotPasswordForm(),
                    ),
                  ),
              ],
            ),
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            OnboardingBackground(profile: activeProfile),
            if (!widget.omitFixedChrome)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: tealBandH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    FormErrorHost.clearAll();
                  },
                  child: const Center(
                    child: AppLogo(
                      size: 100,
                      onWhiteCircle: true,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: tealBandH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    FormErrorHost.clearAll();
                  },
                ),
              ),
            Positioned(left: 0, right: 0, bottom: 0, child: formStack),
            if (!widget.omitFixedChrome)
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: CustomButton(
                    label: AppStrings.back,
                    variant: CustomButtonVariant.ghost,
                    foregroundColor: AppColors.accentLight,
                    onPressed: _handleBack,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Auth Sign In form (used by intro ribbon continuum).
class AuthSignInForm extends GetView<AuthController> {
  const AuthSignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: FormErrorHost(
        formKey: controller.loginFormKey,
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.welcomeBack,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: controller.emailController,
                label: AppStrings.emailAddress,
                hint: 'Email',
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                onChanged: (_) => controller.clearError(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.passwordController,
                label: AppStrings.password,
                hint: 'Password',
                prefixIcon: LucideIcons.lock,
                obscureText: true,
                validator: Validators.password,
                onChanged: (_) => controller.clearError(),
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: AppStrings.forgotPassword,
                  variant: CustomButtonVariant.ghost,
                  foregroundColor: context.scheme.primary,
                  onPressed: () {
                    FormErrorHost.clearAll();
                    controller.openForgotPassword();
                  },
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.errorMessage.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style:
                        context.text.bodySmall?.copyWith(color: AppColors.error),
                  ),
                );
              }),
              Obx(
                () => _AuthPrimaryButton(
                  label: AppStrings.signIn,
                  icon: LucideIcons.logIn,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.login,
                ),
              ),
              const SizedBox(height: 16),
              const SocialDivider(label: AppStrings.signInWith, fontSize: 12),
              const SizedBox(height: 14),
              Obx(
                () => OAuthButton(
                  label: AppStrings.continueWithGoogle,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: () {
                    FormErrorHost.clearAll();
                    controller.continueWithGoogle(intent: AuthIntent.signIn);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount,
                    style: context.text.labelMedium,
                  ),
                  CustomButton(
                    label: AppStrings.signUp,
                    variant: CustomButtonVariant.ghost,
                    foregroundColor: context.scheme.primary,
                    onPressed: () {
                      FormErrorHost.clearAll();
                      controller.showSignUp();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auth Sign Up form (used by intro ribbon continuum).
class AuthSignUpForm extends GetView<AuthController> {
  const AuthSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.createAccount,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: 16),
          RegisterStepSlider(
            part1: FormErrorHost(
              formKey: controller.registerPart1FormKey,
              child: Form(
                key: controller.registerPart1FormKey,
                child: const _RegisterPart1Fields(),
              ),
            ),
            part2: FormErrorHost(
              formKey: controller.registerPart2FormKey,
              child: Form(
                key: controller.registerPart2FormKey,
                child: const _RegisterPart2Fields(),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Obx(() {
            if (controller.errorMessage.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                controller.errorMessage.value,
                style: context.text.bodySmall?.copyWith(color: AppColors.error),
              ),
            );
          }),
          Obx(() {
            final step = controller.registerStep.value;
            final loading = controller.isLoading.value;
            if (step == 0) {
              return _AuthPrimaryButton(
                label: AppStrings.next,
                icon: LucideIcons.chevronRight,
                isLoading: false,
                onPressed: controller.goToRegisterPart2,
              );
            }
            return _AuthPrimaryButton(
              label: AppStrings.signUp,
              icon: LucideIcons.userPlus,
              isLoading: loading,
              onPressed: controller.register,
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            final step = controller.registerStep.value;
            return SocialDivider(
              label: step == 0 ? AppStrings.signInWith : null,
              fontSize: 12,
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final step = controller.registerStep.value;
            if (step == 0) {
              return OAuthButton(
                label: AppStrings.continueWithGoogle,
                isLoading: controller.isGoogleLoading.value,
                onPressed: () {
                  FormErrorHost.clearAll();
                  controller.continueWithGoogle(intent: AuthIntent.register);
                },
              );
            }
            return AuthOutlineButton(
              label: AppStrings.back,
              onPressed: () {
                FormErrorHost.clearAll();
                controller.goToRegisterPart1();
              },
              leading: VitheyIcon(
                LucideIcons.arrowLeft,
                size: 20,
                color: context.appColors.heading,
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.hasAccount,
                style: context.text.labelMedium,
              ),
              CustomButton(
                label: AppStrings.signIn,
                variant: CustomButtonVariant.ghost,
                foregroundColor: context.scheme.primary,
                onPressed: () {
                  FormErrorHost.clearAll();
                  controller.showSignIn();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPart1Fields extends GetView<AuthController> {
  const _RegisterPart1Fields();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: controller.emailController,
          label: AppStrings.emailAddress,
          hint: 'Email',
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: controller.passwordController,
          label: AppStrings.password,
          hint: 'Password',
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          validator: Validators.password,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: controller.confirmPasswordController,
          label: AppStrings.confirmPassword,
          hint: 'Confirm Password',
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          validator: controller.confirmPasswordValidator,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class _RegisterPart2Fields extends GetView<AuthController> {
  const _RegisterPart2Fields();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: controller.fullNameController,
          label: AppStrings.fullName,
          hint: 'Username',
          prefixIcon: LucideIcons.user,
          validator: Validators.fullName,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: controller.phoneController,
          label: AppStrings.phoneNumber,
          hint: '012345678',
          prefixIcon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          onChanged: (_) => controller.clearError(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: controller.dateOfBirthController,
          label: AppStrings.dateOfBirth,
          hint: 'Date of Birth',
          prefixIcon: LucideIcons.calendar,
          readOnly: true,
          validator: Validators.dateOfBirth,
          onTap: () => controller.pickDateOfBirth(context),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

/// Forgot-password form shown inside [AuthRibbonFrame] after teal morph.
class AuthForgotPasswordForm extends GetView<AuthController> {
  const AuthForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Obx(() {
        if (controller.forgotPasswordSuccess.value) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.18
                        : 0.12,
                  ),
                ),
                child: const VitheyIcon(
                  LucideIcons.mailCheck,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.resetLinkSent,
                textAlign: TextAlign.center,
                style: context.text.titleMedium,
              ),
              const SizedBox(height: 24),
              _AuthPrimaryButton(
                label: AppStrings.back,
                icon: LucideIcons.arrowLeft,
                onPressed: controller.closeForgotPassword,
              ),
            ],
          );
        }

        return FormErrorHost(
          formKey: controller.forgotPasswordFormKey,
          child: Form(
            key: controller.forgotPasswordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.forgotPasswordSubtitle,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.appColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: controller.forgotPasswordEmailController,
                  label: AppStrings.emailAddress,
                  hint: 'Email',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  onChanged: (_) {
                    if (controller.forgotPasswordError.isNotEmpty) {
                      controller.forgotPasswordError.value = '';
                    }
                  },
                  textInputAction: TextInputAction.done,
                ),
                Obx(() {
                  if (controller.forgotPasswordError.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.forgotPasswordError.value,
                      style: context.text.bodySmall
                          ?.copyWith(color: AppColors.error),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(
                  () => _AuthPrimaryButton(
                    label: AppStrings.sendResetLink,
                    icon: LucideIcons.send,
                    isLoading: controller.isForgotPasswordLoading.value,
                    onPressed: () async {
                      final ok = await FormErrorHost.submit(
                        controller.forgotPasswordFormKey,
                      );
                      if (ok) controller.requestPasswordReset();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: label,
        icon: icon,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}
