package com.vithey.notification.exception;

import com.vithey.notification.util.ApiResponseWrapper;
import com.vithey.notification.util.ApiResponseWrapper.FieldErrorBody;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.http.ResponseEntity;
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

  @ExceptionHandler(ConstraintViolationException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleConstraintViolation(ConstraintViolationException exception) {
    List<FieldErrorBody> details = exception.getConstraintViolations().stream()
        .map(error -> new FieldErrorBody(error.getPropertyPath().toString(), error.getMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), ErrorCode.VALIDATION_ERROR.defaultMessage(), details));
  }
}
