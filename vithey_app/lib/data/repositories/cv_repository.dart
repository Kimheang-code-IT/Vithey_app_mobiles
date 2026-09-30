import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/fixtures/ai_cv_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/cv_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_pdf_builder.dart';
import 'package:share_plus/share_plus.dart';

class CvRepository {
  CvRepository(this._uploadService, this._api, this._flags);

  final UploadService _uploadService;
  final ApiService _api;
  final FeatureFlags _flags;

  static const maxBytes = 10 * 1024 * 1024;
  static const acceptedExtensions = ['pdf', 'doc', 'docx'];
  static const acceptedMimeTypes = {
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  bool get useMockApi => _flags.useMockApi;

  /// Mock multi-CV library (uploaded + AI). First default seeds from fixture.
  final List<CvMetadataModel> _mockLibrary = [CvFixtures.savedCv()];

  /// Draft snapshots keyed by fileId for in-app preview / re-download.
  final Map<String, AiCvDraft> _draftByFileId = {};

  AiCvDraft? _lastAiDraft;

  AiCvDraft? get lastAiDraft => _lastAiDraft;

  Future<String?> getApplicantCvDownloadUrl(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return CvFixtures.previewUrl;
    }
    final response = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.jobApplicationCvPreview(applicationId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (!response.isSuccess || response.data == null) return null;
    return response.data!['download_url'] as String? ??
        response.data!['url'] as String?;
  }

  /// All saved CVs (mock library). Live API still returns the single default.
  Future<List<CvMetadataModel>> listSavedCvs() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return List<CvMetadataModel>.unmodifiable(
        List<CvMetadataModel>.from(_mockLibrary)
          ..sort((a, b) {
            if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
            final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bAt.compareTo(aAt);
          }),
      );
    }
    final single = await getSavedCv();
    return single == null ? const [] : [single];
  }

  Future<CvMetadataModel?> getSavedCv() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      for (final cv in _mockLibrary) {
        if (cv.isDefault) return cv;
      }
      return _mockLibrary.isEmpty ? null : _mockLibrary.first;
    }
    final response = await _api.get<CvMetadataModel?>(
      ApiEndpoints.usersMeCv,
      fromJson: (json) {
        if (json == null) return null;
        final data = json as Map<String, dynamic>;
        return CvMetadataModel(
          fileId: data['cv_file_id']?.toString() ??
              data['file_id']?.toString() ??
              '',
          fileName: data['file_name'] as String? ?? 'CV',
          mimeType: data['mime_type'] as String? ?? 'application/pdf',
          downloadUrl: data['download_url'] as String?,
          isDefault: true,
        );
      },
    );
    if (!response.isSuccess) return null;
    return response.data;
  }

  Future<CvMetadataModel?> getCvById(String fileId) async {
    final list = await listSavedCvs();
    for (final cv in list) {
      if (cv.fileId == fileId) return cv;
    }
    return null;
  }

  AiCvDraft? draftForFile(String fileId) => _draftByFileId[fileId];

  /// Mock-first CV draft from Vithey profile data.
  /// Live: delegates to [AiRepository.generateCvDraft] → `POST /ai/cv/generate`.
  Future<AiCvDraft> generateCvDraftFromProfile() async {
    if (_flags.useMockAi) {
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      final draft = AiCvFixtures.draftForCurrentUser();
      _lastAiDraft = draft;
      return draft;
    }
    final ai = Get.find<AiRepository>();
    final draft = await ai.generateCvDraft();
    _lastAiDraft = draft;
    return draft;
  }

  /// Persists an AI/blank draft into the CV library (mock PDF on device).
  Future<CvMetadataModel> saveDraftAsCv(
    AiCvDraft draft, {
    String? templateId,
    bool setDefault = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final tplId = templateId ?? draft.templateId;
    final withTpl = draft.copyWith(templateId: tplId);
    _lastAiDraft = withTpl;

    final fileId =
        '${MockIds.cvFileAi}-${DateTime.now().millisecondsSinceEpoch}';

    String? localPath;
    try {
      final template = CvTemplateFixtures.requireById(tplId);
      final file = await CvPdfBuilder.writeTempFile(
        draft: withTpl,
        template: template,
      );
      localPath = file.path;
    } catch (_) {
      localPath = null;
    }

    if (setDefault) {
      for (var i = 0; i < _mockLibrary.length; i++) {
        _mockLibrary[i] = _mockLibrary[i].copyWith(isDefault: false);
      }
    }

    final saved = CvFixtures.aiGeneratedCv(
      fileId: fileId,
      fullName: withTpl.fullName.isEmpty ? 'Blank' : withTpl.fullName,
      templateId: tplId,
      isDefault: setDefault || _mockLibrary.isEmpty,
    ).copyWith(downloadUrl: localPath ?? CvFixtures.previewUrl);

    _mockLibrary.add(saved);
    _draftByFileId[fileId] = withTpl;
    return saved;
  }

  Future<LocalCvFile?> pickLocalCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: acceptedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.path == null) return null;
    return LocalCvFile(
      path: file.path!,
      displayName: file.name,
      sizeBytes: file.size,
      mimeType: _mimeFromExtension(file.extension ?? ''),
    );
  }

  String? validateLocalFile(LocalCvFile file) {
    final ext = file.displayName.split('.').last.toLowerCase();
    if (!acceptedExtensions.contains(ext)) {
      return 'Accepted formats: PDF, DOC, or DOCX';
    }
    if (!acceptedMimeTypes.contains(file.mimeType)) {
      return 'Unsupported file type';
    }
    if (file.sizeBytes <= 0) return 'File is empty';
    if (file.sizeBytes > maxBytes) return 'File must be 10 MB or smaller';
    if (!File(file.path).existsSync()) return 'File no longer available';
    return null;
  }

  Future<UploadedCvFile> uploadCv(LocalCvFile file) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final uploaded = UploadedCvFile(
        fileId: 'uploaded-${DateTime.now().millisecondsSinceEpoch}',
        fileName: file.displayName,
        mimeType: file.mimeType,
        sizeBytes: file.sizeBytes,
      );
      _mockLibrary.add(
        CvMetadataModel(
          fileId: uploaded.fileId,
          fileName: uploaded.fileName,
          mimeType: uploaded.mimeType,
          downloadUrl: file.path,
          createdAt: DateTime.now(),
          isDefault: false,
          isAiGenerated: false,
        ),
      );
      return uploaded;
    }
    return _uploadService.uploadCv(
      filePath: file.path,
      fileName: file.displayName,
      mimeType: file.mimeType,
    );
  }

  Future<void> setDefaultCv(String fileId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      var found = false;
      for (var i = 0; i < _mockLibrary.length; i++) {
        final isMatch = _mockLibrary[i].fileId == fileId;
        if (isMatch) found = true;
        _mockLibrary[i] = _mockLibrary[i].copyWith(isDefault: isMatch);
      }
      if (!found) {
        _mockLibrary.add(
          CvMetadataModel(
            fileId: fileId,
            fileName: 'Updated_CV.pdf',
            mimeType: 'application/pdf',
            downloadUrl: CvFixtures.previewUrl,
            isDefault: true,
            createdAt: DateTime.now(),
          ),
        );
      }
      return;
    }
    final response = await _api.put<void>(
      ApiEndpoints.usersMeCv,
      data: {'cv_file_id': fileId},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw CvRepositoryException(
          response.error?.message ?? 'Could not save default CV');
    }
  }

  Future<void> deleteSavedCv(String fileId) async {
    if (!useMockApi) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final wasDefault =
        _mockLibrary.any((c) => c.fileId == fileId && c.isDefault);
    _mockLibrary.removeWhere((c) => c.fileId == fileId);
    _draftByFileId.remove(fileId);
    if (wasDefault && _mockLibrary.isNotEmpty) {
      _mockLibrary[0] = _mockLibrary[0].copyWith(isDefault: true);
    }
  }

  /// Share / save PDF for a library entry (uses stored draft when available).
  Future<void> downloadSavedCv(CvMetadataModel cv) async {
    final draft = _draftByFileId[cv.fileId];
    if (draft != null) {
      final template = CvTemplateFixtures.requireById(cv.templateId);
      await CvPdfBuilder.sharePdf(draft: draft, template: template);
      return;
    }
    final path = cv.downloadUrl;
    if (path != null &&
        !path.startsWith('http') &&
        File(path).existsSync()) {
      await Share.shareXFiles(
        [XFile(path, mimeType: cv.mimeType, name: cv.fileName)],
        subject: cv.fileName,
      );
      return;
    }
    throw CvRepositoryException('No downloadable file for this CV yet.');
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

class CvRepositoryException implements Exception {
  CvRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
