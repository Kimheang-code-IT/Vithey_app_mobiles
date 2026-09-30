import 'package:aub_connect_app/core/errors/error_mapper.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';

String aiApiErrorMessage(Object error) {
  if (error is AiServiceException) {
    final mapped = ErrorMapper.toAppException(error);
    if (mapped.message.isNotEmpty &&
        mapped.message != error.message &&
        !mapped.message.startsWith('Exception')) {
      return mapped.message;
    }
    final message = error.message.toLowerCase();
    if (message.contains('unauthorized') || message.contains('401')) {
      return 'Please sign in to use Vithey AI.';
    }
    if (message.contains('upstream') ||
        message.contains('502') ||
        message.contains('503')) {
      return 'Vithey AI is temporarily unavailable. Please try again shortly.';
    }
    if (message.contains('session not found') || message.contains('404')) {
      return 'This chat session is no longer available.';
    }
    return error.message;
  }
  return ErrorMapper.userMessage(error);
}
