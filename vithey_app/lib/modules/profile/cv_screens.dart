import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/secure_cv_preview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PreviewOwnCvScreen extends StatefulWidget {
  const PreviewOwnCvScreen({super.key});

  @override
  State<PreviewOwnCvScreen> createState() => _PreviewOwnCvScreenState();
}

class _PreviewOwnCvScreenState extends State<PreviewOwnCvScreen> {
  CvMetadataModel? _cv;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cv = await Get.find<ProfileRepository>().getOwnCv();
    setState(() {
      _cv = cv;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cv?.fileName ?? 'Preview CV'),
        actions: [
          if (_cv?.downloadUrl != null)
            VitheyIconButton(
              icon: LucideIcons.download,
              variant: VitheyIconButtonVariant.neutral,
              tooltip: 'Download CV',
              onTap: () => launchUrl(Uri.parse(_cv!.downloadUrl!), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _cv == null
              ? const EmptyStateWidget(
                  title: 'No CV uploaded yet',
                  subtitle: 'Upload your CV from the apply flow',
                  actionLabel: 'Upload CV',
                )
              : _cv!.downloadUrl == null
                  ? EmptyStateWidget(
                      title: _cv!.fileName,
                      subtitle: 'CV file is saved but preview URL is not available yet.',
                    )
                  : Column(
                  children: [
                    Expanded(
                      child: SecureCvPreview(
                        previewUrl: _cv!.downloadUrl!,
                        mimeType: _cv!.mimeType,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomButton(
                        label: 'Open in browser',
                        onPressed: () => launchUrl(Uri.parse(_cv!.downloadUrl!), mode: LaunchMode.externalApplication),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class ApplicantCvScreen extends GetView<ApplicantCvController> {
  const ApplicantCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as ApplicantCvArgs?;
    return Scaffold(
      appBar: AppBar(title: const Text('View CV')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(args?.applicantName ?? 'Applicant',
                  style: context.text.titleLarge?.copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              Text(args?.cvFileName ?? 'CV document'),
              const SizedBox(height: 16),
              Expanded(
                child: controller.previewUrl.value == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VitheyIcon(LucideIcons.fileText, size: 72, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('CV preview is not available for this application'),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(VitheyRadii.card),
                        child: SecureCvPreview(
                          previewUrl: controller.previewUrl.value!,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Decline',
                      variant: CustomButtonVariant.outline,
                      onPressed: controller.decline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Accept',
                      onPressed: controller.accept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ApplicantCvController extends GetxController {
  ApplicantCvController(this._repository);

  final ProfileRepository _repository;
  final previewUrl = RxnString();
  final isLoading = true.obs;
  String? _applicationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ApplicantCvArgs?;
    _applicationId = args?.applicationId;
    previewUrl.value = args?.cvPreviewUrl;
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (_applicationId == null) {
      isLoading.value = false;
      return;
    }
    if (previewUrl.value != null) {
      isLoading.value = false;
      return;
    }
    try {
      previewUrl.value = await _repository.getApplicantCvPreviewUrl(_applicationId!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept() async {
    if (_applicationId == null) return;
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Accept this application?',
      message: 'The applicant will be notified of your decision.',
      confirmLabel: 'Accept',
    );
    if (confirmed != true) return;
    await _repository.updateApplicationStatus(_applicationId!, ApplicationStatus.accepted);
    Get.back();
    Get.snackbar('Vithey', 'Application accepted');
  }

  Future<void> decline() async {
    if (_applicationId == null) return;
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Decline this application?',
      message: 'The applicant will be notified of your decision.',
      confirmLabel: 'Decline',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    await _repository.updateApplicationStatus(_applicationId!, ApplicationStatus.rejected);
    Get.back();
    Get.snackbar('Vithey', 'Application declined');
  }
}

class ApplicantCvBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicantCvController(Get.find<ProfileRepository>()));
  }
}
