package com.vithey.map.exception;

import com.vithey.map.util.ApiResponseWrapper;
import com.vithey.map.util.ApiResponseWrapper.FieldErrorBody;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(ApiException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleApiException(ApiException exception) {
    return ResponseEntity
        .status(exception.getStatus())
        .body(ApiResponseWrapper.error(exception.getErrorCode().name(), exception.getMessage()));
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

  @ExceptionHandler(HttpMessageNotReadableException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleUnreadableBody(HttpMessageNotReadableException exception) {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.VALIDATION_ERROR.name(), "Malformed request body"));
  }

  @ExceptionHandler(Exception.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleUnexpected(Exception exception) {
    return ResponseEntity.internalServerError()
        .body(ApiResponseWrapper.error(ErrorCode.INTERNAL_ERROR.name(), ErrorCode.INTERNAL_ERROR.defaultMessage()));
  }
}
