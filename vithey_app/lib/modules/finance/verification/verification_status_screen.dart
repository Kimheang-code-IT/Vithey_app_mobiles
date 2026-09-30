import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/submitted_document_card.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/verification_app_bar.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/verification_next_steps_card.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/verification_status_card.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/verification_timeline.dart';

class VerificationStatusController extends GetxController {
  VerificationStatusController(this._repository);

  final StudentVerificationRepository _repository;

  final verification = Rxn<StudentVerificationModel>();
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final provisioningStatus = FinanceProvisioningStatus.ready.obs;

  Timer? _pollTimer;

  /// Mock: pending resolves after 3s — always approved.
  static const _mockPendingDelay = Duration(seconds: 3);

  @override
  void onInit() {
    super.onInit();
    loadVerificationStatus();
  }

  Future<void> loadVerificationStatus() async {
    isLoading.value = true;
    try {
      verification.value = await _repository.getMyVerification();
      _configurePolling();
      _scheduleMockPendingResolution();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshVerificationStatus() async {
    isRefreshing.value = true;
    try {
      verification.value = await _repository.getMyVerification();
      _configurePolling();
      _scheduleMockPendingResolution();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _configurePolling() {
    _pollTimer?.cancel();
    // Outcome is driven by the 3s mock timer, not long polling.
  }

  void _scheduleMockPendingResolution() {
    if (!_repository.useMockApi) return;
    if (verification.value?.status != VerificationStatus.pending) return;
    Future<void>.delayed(_mockPendingDelay, () async {
      if (isClosed) return;
      if (verification.value?.status != VerificationStatus.pending) return;
      verification.value = await _repository.resolveMockPendingOutcome();
    });
  }

  void openVerificationForm() =>
      Get.offNamed(AppRoutes.studentVerification);

  void verifyAgain() => openVerificationForm();

  void contactSupport() {
    final ref = verification.value?.id ?? 'N/A';
    final prompt = 'I need help with my student verification. Reference: $ref';
    Get.toNamed(AppRoutes.chatbot, arguments: prompt);
  }

  Future<void> continueToFinance() async {
    // Re-read authoritative status — never trust a stale success card alone.
    final current = await _repository.getMyVerification();
    verification.value = current;
    if (current.status == VerificationStatus.verified) {
      Get.offNamed(AppRoutes.finance);
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}

class VerificationStatusScreen extends GetView<VerificationStatusController> {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VerificationAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();

        final data = controller.verification.value;
        if (data == null) {
          return const Center(child: Text('Could not load verification status'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshVerificationStatus,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Verification Status',
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                _subtitleFor(data.status),
                style: context.text.bodySmall,
              ),
              const SizedBox(height: 20),
              VerificationStatusCard(status: data.status),
              const SizedBox(height: 24),
              ..._buildBodyFor(context, data),
            ],
          ),
        );
      }),
    );
  }

  String _subtitleFor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Your verification is pending';
      case VerificationStatus.verified:
        return 'Your application has been confirmed';
      case VerificationStatus.rejected:
        return 'Verification failed. Please try again';
      case VerificationStatus.notSubmitted:
        return "You haven't submitted your application yet";
    }
  }

  List<Widget> _buildBodyFor(
    BuildContext context,
    StudentVerificationModel data,
  ) {
    switch (data.status) {
      case VerificationStatus.pending:
        return [
          VerificationTimeline(submittedAt: data.submittedAt),
          const SizedBox(height: 20),
          SubmittedDocumentCard(fileName: data.documentFileName),
          const SizedBox(height: 16),
          const VerificationNextStepsCard(),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Contact the admin',
            onPressed: controller.contactSupport,
          ),
        ];
      case VerificationStatus.verified:
        return [
          if (data.verifiedAt != null)
            Text(
              'Verified on ${_formatDate(data.verifiedAt!)}',
              style: TextStyle(color: context.appColors.muted),
            ),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Continue to Finance',
            onPressed: controller.continueToFinance,
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Verify again',
            variant: CustomButtonVariant.outline,
            onPressed: controller.verifyAgain,
          ),
        ];
      case VerificationStatus.rejected:
        return [
          if (data.rejectionReason != null) ...[
            Text(
              data.rejectionReason!,
              style: TextStyle(
                color: context.appColors.heading,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Verify again',
              onPressed: controller.verifyAgain,
            ),
          ),
        ];
      case VerificationStatus.notSubmitted:
        return [
          const SizedBox(height: 8),
          CustomButton(
            label: 'Verify Student Status',
            onPressed: controller.openVerificationForm,
          ),
        ];
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
