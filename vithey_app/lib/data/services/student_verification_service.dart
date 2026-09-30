import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/models/user_model.dart';

class StudentVerificationService {
  StudentVerificationService(this._api);

  final ApiService _api;

  Future<UserModel> fetchAuthMe() async {
    final response = await _api.get<UserModel>(
      ApiEndpoints.authMe,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw StudentVerificationServiceException(
        response.error?.message ?? 'Failed to load verification status',
      );
    }
    return response.data!;
  }

  Future<StudentVerificationModel> submitVerification({
    required String studentId,
    required String universityEmail,
    String? documentFileId,
  }) async {
    final response = await _api.post<StudentVerificationModel>(
      ApiEndpoints.studentsVerify,
      data: {
        'student_id': studentId,
        'university_email': universityEmail,
        if (documentFileId != null) 'document_file_id': documentFileId,
      },
      fromJson: (json) => _parseVerifyResponse(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw StudentVerificationServiceException(
        response.error?.message ?? 'Verification failed',
      );
    }
    return response.data!;
  }

  StudentVerificationModel _parseVerifyResponse(Map<String, dynamic> json) {
    final statusRaw = json['status']?.toString().toUpperCase();
    final verified = json['is_student_verified'] as bool? ?? false;
    VerificationStatus status;
    switch (statusRaw) {
      case 'PENDING':
        status = VerificationStatus.pending;
      case 'REJECTED':
        status = VerificationStatus.rejected;
      case 'VERIFIED':
        status = VerificationStatus.verified;
      default:
        status = verified
            ? VerificationStatus.verified
            : VerificationStatus.notSubmitted;
    }
    return StudentVerificationModel(
      id: json['user_id']?.toString(),
      status: status,
      studentId: json['student_id'] as String?,
      universityEmail: json['university_email'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : (verified ? DateTime.now() : null),
      canResubmit: status == VerificationStatus.rejected,
    );
  }
}

class StudentVerificationServiceException implements Exception {
  StudentVerificationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
