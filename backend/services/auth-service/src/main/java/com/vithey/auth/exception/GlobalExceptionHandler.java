package com.vithey.auth.exception;

import com.vithey.auth.util.ApiResponseWrapper;
import com.vithey.auth.util.ApiResponseWrapper.FieldErrorBody;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  @ExceptionHandler(ApiException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleApiException(ApiException exception) {
    ErrorCode errorCode = exception.getErrorCode();
    return ResponseEntity
        .status(errorCode.status())
        .body(ApiResponseWrapper.error(errorCode.name(), exception.getMessage()));
  }

  @ExceptionHandler(DataAccessException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleDataAccess(DataAccessException exception) {
    log.error("Persistence failure", exception);
    return ResponseEntity
        .status(ErrorCode.INTERNAL_ERROR.status())
        .body(ApiResponseWrapper.error(ErrorCode.INTERNAL_ERROR.name(), ErrorCode.INTERNAL_ERROR.defaultMessage()));
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
