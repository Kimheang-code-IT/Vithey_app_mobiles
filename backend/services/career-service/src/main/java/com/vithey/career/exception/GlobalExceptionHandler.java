package com.vithey.career.exception;

import com.vithey.career.util.ApiResponseWrapper;
import com.vithey.career.util.ApiResponseWrapper.FieldErrorBody;
import feign.FeignException;
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

  @ExceptionHandler(FeignException.NotFound.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleRemoteNotFound() {
    return ResponseEntity.status(ErrorCode.NOT_FOUND.status())
        .body(ApiResponseWrapper.error(ErrorCode.NOT_FOUND.name(), ErrorCode.NOT_FOUND.defaultMessage()));
  }

  @ExceptionHandler(FeignException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleFeign(FeignException exception) {
    if (exception instanceof FeignException.NotFound) {
      return handleRemoteNotFound();
    }
    return ResponseEntity.status(ErrorCode.UPSTREAM_ERROR.status())
        .body(ApiResponseWrapper.error(ErrorCode.UPSTREAM_ERROR.name(), ErrorCode.UPSTREAM_ERROR.defaultMessage()));
  }
}
