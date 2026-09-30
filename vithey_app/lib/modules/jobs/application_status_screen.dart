import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/jobs/models/application_detail_model.dart';
import 'package:aub_connect_app/modules/jobs/models/application_status_args.dart';
import 'package:aub_connect_app/modules/jobs/widgets/application_status_widgets.dart';

class ApplicationStatusController extends GetxController {
  ApplicationStatusController(this._repository);

  final JobApplicationRepository _repository;

  final detail = Rxn<ApplicationDetailModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  String? _applicationId;

  @override
  void onInit() {
    super.onInit();
    final args = ApplicationStatusArgs.from(Get.arguments);
    _applicationId = args.applicationId;
    loadStatus();
  }

  Future<void> loadStatus() async {
    if (_applicationId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      detail.value = await _repository.getApplicationDetail(_applicationId!);
    } catch (e) {
      errorMessage.value = AppStrings.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cycleMockStatus() async {
    if (_applicationId == null || detail.value == null) return;
    final current = detail.value!.status;
    final next = switch (current) {
      ApplicationStatus.pending => ApplicationStatus.reviewed,
      ApplicationStatus.reviewed => ApplicationStatus.accepted,
      ApplicationStatus.accepted => ApplicationStatus.rejected,
      ApplicationStatus.rejected => ApplicationStatus.pending,
    };
    await _repository.setMockApplicationStatus(_applicationId!, next);
    await loadStatus();
  }
}

class ApplicationStatusScreen extends GetView<ApplicationStatusController> {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: context.appColors.heading,
        title: Text(AppStrings.applyStatusTitle, style: context.text.headlineSmall),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.errorMessage.value.isNotEmpty || controller.detail.value == null) {
          return AppErrorWidget(
            message: controller.errorMessage.value.isEmpty
                ? AppStrings.errorGeneric
                : controller.errorMessage.value,
            onRetry: controller.loadStatus,
          );
        }

        final data = controller.detail.value!;
        final showStandaloneTimeline = data.status != ApplicationStatus.accepted &&
            data.status != ApplicationStatus.rejected;

        return RefreshIndicator(
          onRefresh: controller.loadStatus,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (showStandaloneTimeline) ...[
                ApplicationStatusHero(detail: data),
                const SizedBox(height: 28),
                ApplicationTimeline(steps: data.buildTimeline()),
                const SizedBox(height: 20),
                StatusBannerCard(message: data.bannerMessage),
              ] else ...[
                ApplicationStatusHero(detail: data, inCard: true),
              ],
              if (data.reviewerNote != null && data.reviewerNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                StatusMessageCard(message: data.reviewerNote!),
              ],
              if (Get.find<FeatureFlags>().showMockDevTools && kDebugMode) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: controller.cycleMockStatus,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Demo: cycle status (mock only)',
                      style: TextStyle(color: AppColors.pending),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
