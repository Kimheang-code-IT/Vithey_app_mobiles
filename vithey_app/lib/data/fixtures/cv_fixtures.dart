import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

abstract final class CvFixtures {
  static const previewUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  static CvMetadataModel savedCv() {
    return CvMetadataModel(
      fileId: MockIds.cvFile,
      fileName: '${MockIdentities.mockUserFullName.replaceAll(' ', '_')}_CV.pdf',
      mimeType: 'application/pdf',
      downloadUrl: previewUrl,
      isDefault: true,
      isAiGenerated: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );
  }

  static CvMetadataModel aiGeneratedCv({
    String? fileId,
    String? fullName,
    String? templateId,
    bool isDefault = true,
  }) {
    final name =
        (fullName ?? MockIdentities.mockUserFullName).replaceAll(' ', '_');
    return CvMetadataModel(
      fileId: fileId ?? MockIds.cvFileAi,
      fileName: '${name}_AI_CV.pdf',
      mimeType: 'application/pdf',
      downloadUrl: previewUrl,
      templateId: templateId,
      createdAt: DateTime.now(),
      isDefault: isDefault,
      isAiGenerated: true,
    );
  }
}
