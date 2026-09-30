import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/widgets/choose_saved_cv_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_success_args.dart';
import 'package:aub_connect_app/modules/jobs/models/application_status_args.dart';

enum ApplyCvPhase {
  loadingJob,
  ready,
  uploadingCv,
  applying,
  error,
}

enum ApplyCvStep { upload, review }

enum CvSelectionMode {
  none,
  saved,
  localApplicationOnly,
  localUpdateDefault,
}

class ApplyCvController extends GetxController {
  ApplyCvController(this._cvRepository, this._jobApplicationRepository);

  final CvRepository _cvRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final phase = ApplyCvPhase.loadingJob.obs;
  final currentStep = ApplyCvStep.upload.obs;
  final job = Rxn<FeedPost>();
  final eligibility = Rxn<JobEligibilityResult>();
  final savedCv = Rxn<CvMetadataModel>();
  final savedCvs = <CvMetadataModel>[].obs;
  final localCv = Rxn<LocalCvFile>();
  final selectionMode = CvSelectionMode.none.obs;
  final saveAsDefault = false.obs;
  final fileError = ''.obs;
  final submitError = ''.obs;
  final submitLabel = AppStrings.submitApplication.obs;
  final isSubmitting = false.obs;
  final selectedPosition = RxnString();

  final descriptionController = TextEditingController();

  String? _jobPostId;

  /// Exposed for the AI match card on the Review step (Block 5).
  String? get jobPostId => _jobPostId;
  String? _preferredCvFileId;
  bool _openOnReview = false;
  String? _uploadedFileId;
  bool _submitLocked = false;

  bool get canContinue {
    if (phase.value != ApplyCvPhase.ready) return false;
    if (isSubmitting.value) return false;
    if (eligibility.value?.eligibility != JobEligibility.eligible) return false;
    if (selectedPosition.value?.trim().isNotEmpty != true) return false;
    if (!_hasValidCv) return false;
    return true;
  }

  bool get canSubmit {
    if (currentStep.value != ApplyCvStep.review) return false;
    return canContinue;
  }

  bool get _hasValidCv {
    if (selectionMode.value == CvSelectionMode.saved && savedCv.value != null) {
      return true;
    }
    if (localCv.value != null && fileError.value.isEmpty) return true;
    return false;
  }

  String get acceptedPolicyLabel => AppStrings.cvPolicyLabel;

  String get selectedFileName {
    if (selectionMode.value == CvSelectionMode.saved && savedCv.value != null) {
      return savedCv.value!.fileName;
    }
    return localCv.value?.displayName ?? '';
  }

  String get selectedFileSizeLabel {
    if (localCv.value != null) return localCv.value!.formattedSize;
    if (savedCv.value != null) return savedCv.value!.mimeType;
    return '';
  }

  String get jobTitle =>
      job.value?.jobMeta.title ?? job.value?.content ?? 'this role';

  String get organizationName {
    final company = job.value?.jobMeta.description?.trim();
    if (company != null && company.isNotEmpty) {
      // Prefer the company segment before " · " when description is enriched.
      final companyOnly = company.split(' · ').first.trim();
      return companyOnly.isNotEmpty ? companyOnly : company;
    }
    return job.value?.author.fullName ?? '';
  }

  String get positionLabel => selectedPosition.value ?? '';

  bool get hasDetectedPosition =>
      selectedPosition.value?.trim().isNotEmpty == true;

  bool get isAlreadyApplied =>
      eligibility.value?.eligibility == JobEligibility.alreadyApplied;

  String? get existingApplicationId => eligibility.value?.existingApplicationId;

  void viewApplicationStatus() {
    final applicationId = existingApplicationId;
    if (applicationId == null || applicationId.isEmpty) {
      Get.snackbar(AppStrings.appName, AppStrings.applyStatusUnavailable);
      return;
    }
    Get.toNamed(
      AppRoutes.applicationStatus,
      arguments: ApplicationStatusArgs(
        applicationId: applicationId,
        jobPostId: _jobPostId,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = ApplyCvArgs.from(Get.arguments);
    _jobPostId = args.jobPostId;
    _preferredCvFileId = args.preferredCvFileId;
    _openOnReview = args.openOnReview;
    if (args.jobPreview != null) job.value = args.jobPreview;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    phase.value = ApplyCvPhase.loadingJob;
    submitError.value = '';
    try {
      final results = await Future.wait([
        _jobApplicationRepository.loadJobEligibility(_jobPostId!),
        _cvRepository.getSavedCv(),
        _cvRepository.listSavedCvs(),
      ]);
      final eligibilityResult = results[0] as JobEligibilityResult;
      final saved = results[1] as CvMetadataModel?;
      final library = results[2] as List<CvMetadataModel>;

      eligibility.value = eligibilityResult;
      job.value = eligibilityResult.job ?? job.value;
      savedCvs.assignAll(library);
      savedCv.value = saved;

      final detectedPosition = job.value?.jobMeta.title?.trim();
      selectedPosition.value =
          detectedPosition?.isNotEmpty == true ? detectedPosition : null;

      final preferredId = _preferredCvFileId;
      if (preferredId != null && preferredId.isNotEmpty) {
        CvMetadataModel? preferred;
        for (final c in library) {
          if (c.fileId == preferredId) {
            preferred = c;
            break;
          }
        }
        if (preferred != null) {
          savedCv.value = preferred;
          selectionMode.value = CvSelectionMode.saved;
        } else if (saved != null && saved.fileId == preferredId) {
          selectionMode.value = CvSelectionMode.saved;
        } else if (_cvRepository.useMockApi && saved != null) {
          selectionMode.value = CvSelectionMode.saved;
        } else {
          selectionMode.value = CvSelectionMode.none;
        }
      } else if (_cvRepository.useMockApi && saved != null) {
        selectionMode.value = CvSelectionMode.saved;
      } else {
        selectionMode.value = CvSelectionMode.none;
      }

      phase.value = ApplyCvPhase.ready;

      if (_openOnReview && canContinue) {
        currentStep.value = ApplyCvStep.review;
      }
    } catch (e) {
      phase.value = ApplyCvPhase.error;
      submitError.value = AppStrings.applyJobLoadError;
    }
  }

  void openAiCvCreator() {
    final jobPostId = _jobPostId;
    if (jobPostId == null) return;
    Get.offNamed(
      AppRoutes.applyCvTemplates,
      arguments: AiCvArgs(
        jobPostId: jobPostId,
        jobPreview: job.value,
        returnToApply: true,
      ),
    );
  }

  Future<void> openChooseSavedCv(BuildContext context) async {
    if (savedCvs.isEmpty) return;
    final picked = await ChooseSavedCvSheet.show(
      context,
      cvs: List<CvMetadataModel>.from(savedCvs),
      draftFor: _cvRepository.draftForFile,
      selectedFileId: savedCv.value?.fileId,
    );
    if (picked == null) return;
    selectSavedCv(picked);
  }

  void selectSavedCv(CvMetadataModel cv) {
    savedCv.value = cv;
    localCv.value = null;
    fileError.value = '';
    selectionMode.value = CvSelectionMode.saved;
    saveAsDefault.value = false;
  }

  Future<void> retryLoad() => _loadInitialData();

  Future<void> pickLocalCv({required bool updateDefault}) async {
    fileError.value = '';
    final picked = await _cvRepository.pickLocalCv();
    if (picked == null) return;

    final validationError = _cvRepository.validateLocalFile(picked);
    if (validationError != null) {
      fileError.value = validationError;
      localCv.value = picked;
      selectionMode.value = updateDefault
          ? CvSelectionMode.localUpdateDefault
          : CvSelectionMode.localApplicationOnly;
      return;
    }

    localCv.value = picked;
    selectionMode.value = updateDefault
        ? CvSelectionMode.localUpdateDefault
        : CvSelectionMode.localApplicationOnly;
    saveAsDefault.value = updateDefault;
  }

  void useSavedCv() {
    if (savedCv.value == null) return;
    localCv.value = null;
    fileError.value = '';
    selectionMode.value = CvSelectionMode.saved;
    saveAsDefault.value = false;
  }

  void clearCvSelection() {
    localCv.value = null;
    fileError.value = '';
    selectionMode.value = CvSelectionMode.none;
    saveAsDefault.value = false;
  }

  void removeLocalCv() {
    localCv.value = null;
    fileError.value = '';
    if (savedCv.value != null) {
      selectionMode.value = CvSelectionMode.saved;
    } else {
      selectionMode.value = CvSelectionMode.none;
    }
    saveAsDefault.value = false;
  }

  void removeCvAndGoBack() {
    clearCvSelection();
    currentStep.value = ApplyCvStep.upload;
  }

  void toggleSaveAsDefault(bool value) => saveAsDefault.value = value;

  void goToReview() {
    if (!canContinue) return;
    submitError.value = '';
    currentStep.value = ApplyCvStep.review;
  }

  void goToUpload() {
    if (isSubmitting.value) return;
    currentStep.value = ApplyCvStep.upload;
  }

  Future<bool> handleBack() async {
    if (currentStep.value == ApplyCvStep.review) {
      goToUpload();
      return false;
    }
    if (_hasValidCv || descriptionController.text.trim().isNotEmpty) {
      final discard = await showConfirmDialog(
        context: Get.context!,
        title: AppStrings.discardApplicationTitle,
        message: AppStrings.discardApplicationMessage,
        confirmLabel: AppStrings.discard,
        variant: ConfirmDialogVariant.destructive,
      );
      return discard == true;
    }
    return true;
  }

  Future<void> submit() async {
    if (!canSubmit || _submitLocked || _jobPostId == null) return;
    _submitLocked = true;
    isSubmitting.value = true;
    submitError.value = '';

    try {
      final refreshed =
          await _jobApplicationRepository.loadJobEligibility(_jobPostId!);
      eligibility.value = refreshed;
      job.value = refreshed.job ?? job.value;
      if (refreshed.eligibility != JobEligibility.eligible) {
        submitError.value = refreshed.message ?? AppStrings.applyJobNotEligible;
        return;
      }

      String cvFileId;
      String? cvFileName;
      if (selectionMode.value == CvSelectionMode.saved) {
        cvFileId = savedCv.value!.fileId;
        cvFileName = savedCv.value!.fileName;
      } else {
        final local = localCv.value!;
        final validationError = _cvRepository.validateLocalFile(local);
        if (validationError != null) {
          fileError.value = validationError;
          return;
        }

        if (_uploadedFileId == null) {
          phase.value = ApplyCvPhase.uploadingCv;
          submitLabel.value = AppStrings.uploadingCv;
          final uploaded = await _cvRepository.uploadCv(local);
          _uploadedFileId = uploaded.fileId;
        }
        cvFileId = _uploadedFileId!;
        cvFileName = local.displayName;

        if (saveAsDefault.value ||
            selectionMode.value == CvSelectionMode.localUpdateDefault) {
          await _cvRepository.setDefaultCv(cvFileId);
          savedCv.value = CvMetadataModel(
            fileId: cvFileId,
            fileName: local.displayName,
            mimeType: local.mimeType,
          );
        }
      }

      phase.value = ApplyCvPhase.applying;
      submitLabel.value = AppStrings.submittingApplication;
      final note = descriptionController.text.trim();
      final result = await _jobApplicationRepository.submitApplication(
        jobPostId: _jobPostId!,
        cvFileId: cvFileId,
        applicationNote: note.isEmpty ? null : note,
        jobTitle: jobTitle,
        organization: organizationName,
        cvFileName: cvFileName,
      );

      final successArgs = ApplySuccessArgs(
        applicationId: result.applicationId,
        jobPostId: result.jobPostId,
        jobTitle: jobTitle,
        result: result,
      );
      await Get.toNamed(AppRoutes.applySuccess, arguments: successArgs);
      Get.back(result: result);
    } catch (e) {
      phase.value = ApplyCvPhase.ready;
      currentStep.value = ApplyCvStep.review;
      final message = switch (e) {
        JobApplicationServiceException() => e.message,
        CvRepositoryException() => e.message,
        UploadServiceException() => e.message,
        _ => AppStrings.applyJobSubmitError,
      };
      submitError.value = message;
    } finally {
      isSubmitting.value = false;
      submitLabel.value = AppStrings.submitApplication;
      _submitLocked = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
