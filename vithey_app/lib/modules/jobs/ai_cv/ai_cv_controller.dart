import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_pdf_builder.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_preview.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:get/get.dart';

enum AiCvPhase { generating, preview, saving, error }

class AiCvController extends GetxController {
  AiCvController(this._aiRepository, this._cvRepository);

  final AiRepository _aiRepository;
  final CvRepository _cvRepository;

  final phase = AiCvPhase.generating.obs;
  final draft = Rxn<AiCvDraft>();
  final errorMessage = ''.obs;
  final isSaving = false.obs;
  final isRegeneratingSummary = false.obs;
  final isDownloading = false.obs;
  final activeSection = Rxn<CvEditSection>();
  int _summaryVariant = 0;

  String? _jobPostId;
  FeedPost? _jobPreview;
  bool _returnToApply = true;
  String? _templateId;
  bool _blank = false;

  bool get hasJobContext =>
      _returnToApply && (_jobPostId?.isNotEmpty ?? false);

  String get jobTitle =>
      _jobPreview?.jobMeta.title ?? _jobPreview?.content ?? 'this role';

  CvTemplate get selectedTemplate =>
      CvTemplateFixtures.requireById(_templateId);

  String? get templateId => _templateId;
  bool get isBlank => _blank;

  @override
  void onInit() {
    super.onInit();
    final args = AiCvArgs.from(Get.arguments);
    _jobPostId = args.jobPostId;
    _jobPreview = args.jobPreview;
    _returnToApply = args.returnToApply;
    _templateId = args.templateId ?? CvTemplateFixtures.all.first.id;
    _blank = args.blank;
    _generate();
  }

  Future<void> _generate() async {
    phase.value = AiCvPhase.generating;
    errorMessage.value = '';
    try {
      if (_blank) {
        draft.value = AiCvDraft(
          fullName: '',
          summary: '',
          skills: const [],
          education: const [],
          experience: const [],
          projects: const [],
          contact: '',
          templateId: _templateId,
        );
        _summaryVariant = 0;
        phase.value = AiCvPhase.preview;
        return;
      }

      final result = await _aiRepository.generateCvDraft();
      final withTemplate = result.copyWith(templateId: _templateId);
      draft.value = withTemplate;
      _summaryVariant = 0;
      if (withTemplate.incompleteProfile) {
        phase.value = AiCvPhase.error;
        errorMessage.value = withTemplate.incompleteMessage ??
            'Complete your profile first so Vithey AI can build your CV.';
        return;
      }
      phase.value = AiCvPhase.preview;
    } catch (e) {
      phase.value = AiCvPhase.error;
      final detail = e is AiServiceException ? e.message : null;
      errorMessage.value = (detail != null && detail.trim().isNotEmpty)
          ? detail
          : 'Could not generate a CV draft. Please try again.';
    }
  }

  String sectionValue(CvEditSection section) {
    final d = draft.value;
    if (d == null) return '';
    switch (section) {
      case CvEditSection.fullName:
        return d.fullName;
      case CvEditSection.summary:
        return d.summary;
      case CvEditSection.skills:
        return d.skills.join(', ');
      case CvEditSection.education:
        return d.education.join('\n');
      case CvEditSection.experience:
        return d.experience.join('\n');
      case CvEditSection.projects:
        return d.projects.join('\n');
      case CvEditSection.contact:
        return d.contact;
    }
  }

  void updateSection(CvEditSection section, String raw) {
    final base = draft.value;
    if (base == null) return;
    List<String> lines(String value, {bool commas = false}) {
      final pattern = commas ? RegExp(r'[\n,]') : RegExp(r'\n');
      return value
          .split(pattern)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    draft.value = switch (section) {
      CvEditSection.fullName => base.copyWith(fullName: raw.trim()),
      CvEditSection.summary => base.copyWith(summary: raw.trim()),
      CvEditSection.skills => base.copyWith(skills: lines(raw, commas: true)),
      CvEditSection.education => base.copyWith(education: lines(raw)),
      CvEditSection.experience => base.copyWith(experience: lines(raw)),
      CvEditSection.projects => base.copyWith(projects: lines(raw)),
      CvEditSection.contact => base.copyWith(contact: raw.trim()),
    };
  }

  /// Mock regenerate: reshuffles fixture wording — still profile-only facts.
  Future<void> regenerateSummary() async {
    if (isRegeneratingSummary.value || _blank) return;
    isRegeneratingSummary.value = true;
    try {
      final next = await _aiRepository.regenerateCvSummary(
        variant: ++_summaryVariant,
        originalText: draft.value?.summary,
      );
      final base = draft.value;
      if (base != null) draft.value = base.copyWith(summary: next);
    } catch (_) {
      Get.snackbar('Vithey', 'Could not regenerate the summary. Try again.');
    } finally {
      isRegeneratingSummary.value = false;
    }
  }

  Future<void> retryGenerate() => _generate();

  void cancelToApply() {
    if (!hasJobContext) {
      Get.back();
      return;
    }
    final jobPostId = _jobPostId!;
    Get.offNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(
        jobPostId: jobPostId,
        jobPreview: _jobPreview,
      ),
    );
  }

  Future<void> confirmUseForJob() async {
    await _saveAndReturn(openOnReview: true);
  }

  Future<void> saveOnly() async {
    await _saveAndReturn(openOnReview: false);
  }

  Future<void> downloadPdf() async {
    if (isDownloading.value) return;
    final current = draft.value;
    if (current == null) return;
    isDownloading.value = true;
    try {
      await CvPdfBuilder.sharePdf(
        draft: current,
        template: selectedTemplate,
      );
    } catch (_) {
      Get.snackbar('Vithey', 'Could not create the PDF. Please try again.');
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> _saveAndReturn({required bool openOnReview}) async {
    if (isSaving.value) return;
    final current = draft.value;
    if (current == null) return;
    isSaving.value = true;
    phase.value = AiCvPhase.saving;
    try {
      final saved = await _cvRepository.saveDraftAsCv(
        current.copyWith(templateId: _templateId),
        templateId: _templateId,
        setDefault: true,
      );
      if (!hasJobContext) {
        Get.snackbar('Vithey', 'AI CV saved to your profile.');
        Get.back(result: saved);
        return;
      }
      final jobPostId = _jobPostId!;
      Get.offNamed(
        AppRoutes.applyCv,
        arguments: ApplyCvArgs(
          jobPostId: jobPostId,
          jobPreview: _jobPreview,
          preferredCvFileId: saved.fileId,
          openOnReview: openOnReview,
        ),
      );
    } catch (_) {
      phase.value = AiCvPhase.preview;
      Get.snackbar('Vithey', 'Could not save AI CV. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }
}
