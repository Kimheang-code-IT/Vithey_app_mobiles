import 'dart:io';

import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';

class UploadService {
  UploadService(this._dioClient);

  final DioClient _dioClient;

  Future<UploadedCvFile> uploadCv({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    return _uploadFile(
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
      type: 'CV',
    );
  }

  Future<UploadedMediaFile> uploadPostMedia({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String type,
  }) async {
    final result = await _uploadFile(
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
      type: type,
    );
    return UploadedMediaFile(
      fileId: result.fileId,
      fileName: result.fileName,
      mimeType: result.mimeType,
      sizeBytes: result.sizeBytes,
    );
  }

  Future<UploadedCvFile> _uploadFile({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String type,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'type': type,
    });

    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.filesUpload,
        data: formData,
      );

      final body = response.data ?? {};
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        throw UploadServiceException(error['message'] as String? ?? 'Upload failed');
      }

      final data = body['data'] as Map<String, dynamic>? ?? body;
      final fileId = data['file_id']?.toString() ?? data['id']?.toString() ?? '';
      if (fileId.isEmpty) {
        throw UploadServiceException('Upload failed');
      }
      return UploadedCvFile(
        fileId: fileId,
        fileName: data['file_name'] as String? ?? fileName,
        mimeType: data['mime_type'] as String? ?? mimeType,
        sizeBytes: data['size_bytes'] as int? ?? File(filePath).lengthSync(),
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        final apiError = body['error'];
        if (apiError is Map<String, dynamic>) {
          throw UploadServiceException(apiError['message'] as String? ?? 'Upload failed');
        }
      }
      throw UploadServiceException(error.message ?? 'Upload failed');
    }
  }
}

class UploadedMediaFile {
  const UploadedMediaFile({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String fileId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
}

class UploadServiceException implements Exception {
  UploadServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
