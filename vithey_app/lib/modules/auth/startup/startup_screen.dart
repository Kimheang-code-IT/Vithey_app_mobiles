import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/modules/auth/startup/startup_controller.dart';
import 'package:aub_connect_app/modules/auth/startup/startup_step_pages.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_app_bar.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_bottom_navigation.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_content_switcher.dart';

/// Single Startup shell — fixed AppBar + bottom; content slides between steps.
class StartupScreen extends GetView<StartupController> {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenBody(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StartupAppBar(onSkip: controller.skipAll),
              Expanded(
                child: StartupContentSwitcher(
                  pages: const [
                    StartupSkillsPage(),
                    StartupInterestsPage(),
                    StartupDiscoveryPage(),
                  ],
                ),
              ),
              Obx(() {
                final step = controller.currentStep.value;
                return StartupBottomNavigation(
                  currentStep: step,
                  showBack: step > 0,
                  onBack: step > 0 ? controller.back : null,
                  onNext: controller.next,
                  nextLabel: step == 2 ? 'Finish' : AppStrings.next,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
