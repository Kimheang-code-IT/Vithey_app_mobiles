import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/errors/app_exception.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/post_search_service.dart';
import 'package:aub_connect_app/data/services/post_service.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/data/services/user_search_service.dart';

/// Maps low-level errors to user-friendly messages and [AppException].
class ErrorMapper {
  const ErrorMapper._();

  static AppException toAppException(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return _fromDio(error);
    if (error is AuthServiceException) {
      return AppException(kind: AppErrorKind.unauthorized, message: error.message, cause: error);
    }
    if (error is ProfileServiceException) {
      return AppException(kind: AppErrorKind.unknown, message: error.message, cause: error);
    }
    if (error is PostServiceException) {
      return AppException(kind: AppErrorKind.unknown, message: error.message, cause: error);
    }
    if (error is AiServiceException) {
      return AppException(kind: _aiKind(error.message), message: error.message, cause: error);
    }
    if (error is UploadServiceException) {
      return AppException(kind: AppErrorKind.unknown, message: error.message, cause: error);
    }
    if (error is UserSearchServiceException || error is PostSearchServiceException) {
      final message = error is UserSearchServiceException
          ? error.message
          : (error as PostSearchServiceException).message;
      return AppException(kind: AppErrorKind.unknown, message: message, cause: error);
    }
    return AppException(
      kind: AppErrorKind.unknown,
      message: error.toString().replaceFirst('Exception: ', ''),
      cause: error,
    );
  }

  static String userMessage(Object error) {
    final mapped = toAppException(error);
    switch (mapped.kind) {
      case AppErrorKind.network:
        return 'Network error. Check your connection and try again.';
      case AppErrorKind.unauthorized:
        return mapped.message.isNotEmpty ? mapped.message : 'Please sign in to continue.';
      case AppErrorKind.notFound:
        return mapped.message.isNotEmpty ? mapped.message : 'The requested item is no longer available.';
      case AppErrorKind.upstream:
        return 'Service is temporarily unavailable. Please try again shortly.';
      case AppErrorKind.validation:
        return mapped.message;
      case AppErrorKind.conflict:
        return mapped.message.isNotEmpty ? mapped.message : 'This action conflicts with current data.';
      case AppErrorKind.unknown:
        return mapped.message.isNotEmpty ? mapped.message : 'Something went wrong. Please try again.';
    }
  }

  static AppException _fromDio(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    String? apiMessage;
    String? apiCode;
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map<String, dynamic>) {
        apiMessage = err['message'] as String?;
        apiCode = err['code'] as String?;
      }
    }

    if (status == 401) {
      return AppException(
        kind: AppErrorKind.unauthorized,
        message: apiMessage ?? 'Please sign in to continue.',
        code: apiCode,
        cause: error,
      );
    }
    if (status == 404) {
      return AppException(
        kind: AppErrorKind.notFound,
        message: apiMessage ?? 'Resource not found.',
        code: apiCode,
        cause: error,
      );
    }
    if (status == 409) {
      return AppException(
        kind: AppErrorKind.conflict,
        message: apiMessage ?? 'Conflict with existing data.',
        code: apiCode,
        cause: error,
      );
    }
    if (status != null && status >= 500) {
      return AppException(
        kind: AppErrorKind.upstream,
        message: apiMessage ?? 'Server error. Please try again later.',
        code: apiCode,
        cause: error,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return AppException(
        kind: AppErrorKind.network,
        message: apiMessage ?? 'Network request failed.',
        code: apiCode,
        cause: error,
      );
    }
    return AppException(
      kind: AppErrorKind.unknown,
      message: apiMessage ?? error.message ?? 'Request failed.',
      code: apiCode,
      cause: error,
    );
  }

  static AppErrorKind _aiKind(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('unauthorized') || lower.contains('401')) {
      return AppErrorKind.unauthorized;
    }
    if (lower.contains('upstream') || lower.contains('502') || lower.contains('503')) {
      return AppErrorKind.upstream;
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return AppErrorKind.notFound;
    }
    return AppErrorKind.unknown;
  }
}
