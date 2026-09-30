package com.vithey.profile.exception;

import com.vithey.profile.util.ApiResponseWrapper;
import com.vithey.profile.util.ApiResponseWrapper.FieldErrorBody;
import feign.FeignException;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(ApiException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleApiException(ApiException exception) {
    ErrorCode errorCode = exception.getErrorCode();
    return ResponseEntity
        .status(errorCode.status())
        .body(ApiResponseWrapper.error(errorCode.name(), exception.getMessage()));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleValidation(MethodArgumentNotValidException exception) {
    List<FieldErrorBody> details = exception.getBindingResult().getFieldErrors().stream()
        .map(error -> new FieldErrorBody(error.getField(), error.getDefaultMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }

  @ExceptionHandler(MissingServletRequestParameterException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleMissingParameter(MissingServletRequestParameterException exception) {
    List<FieldErrorBody> details = List.of(
        new FieldErrorBody(exception.getParameterName(), "Required parameter is missing"));
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }

  @ExceptionHandler(ConstraintViolationException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleConstraintViolation(ConstraintViolationException exception) {
    List<FieldErrorBody> details = exception.getConstraintViolations().stream()
        .map(error -> new FieldErrorBody(error.getPropertyPath().toString(), error.getMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }

  @ExceptionHandler(FeignException.NotFound.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleFileNotFound() {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.INVALID_FILE.name(), ErrorCode.INVALID_FILE.defaultMessage()));
  }
}
