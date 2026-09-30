import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/login_screen.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Standalone Forgot Password route — same wave UI as Sign In continuum.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    auth.resetForgotPasswordState();
    auth.showForgotPassword.value = true;
  }

  void _goBack() {
    final auth = Get.find<AuthController>();
    auth.closeForgotPassword();
    FormErrorHost.clearAll();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.appColors.cardSurface,
      body: AuthRibbonFrame(
        profile: WaveRibbon.signIn,
        form: const SizedBox.shrink(),
        onBack: _goBack,
        enableForgotMorph: true,
        startOnForgot: true,
      ),
    );
  }
}
