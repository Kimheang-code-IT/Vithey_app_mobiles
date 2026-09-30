package com.vithey.file.exception;

import com.vithey.file.util.ApiResponseWrapper;
import com.vithey.file.util.ApiResponseWrapper.FieldErrorBody;
import jakarta.validation.ConstraintViolationException;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;

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
        .body(ApiResponseWrapper.error(
            ErrorCode.VALIDATION_ERROR.name(),
            ErrorCode.VALIDATION_ERROR.defaultMessage(),
            details
        ));
  }

  @ExceptionHandler(ConstraintViolationException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleConstraintViolation(ConstraintViolationException exception) {
    List<FieldErrorBody> details = exception.getConstraintViolations().stream()
        .map(error -> new FieldErrorBody(error.getPropertyPath().toString(), error.getMessage()))
        .toList();
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(
            ErrorCode.VALIDATION_ERROR.name(),
            ErrorCode.VALIDATION_ERROR.defaultMessage(),
            details
        ));
  }

  @ExceptionHandler(MethodArgumentTypeMismatchException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleTypeMismatch(MethodArgumentTypeMismatchException exception) {
    String field = exception.getName() == null ? "parameter" : exception.getName();
    String message = "Invalid value for " + field;
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(
            ErrorCode.VALIDATION_ERROR.name(),
            ErrorCode.VALIDATION_ERROR.defaultMessage(),
            List.of(new FieldErrorBody(field, message))
        ));
  }

  @ExceptionHandler(MissingServletRequestParameterException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleMissingParameter(MissingServletRequestParameterException exception) {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(
            ErrorCode.VALIDATION_ERROR.name(),
            ErrorCode.VALIDATION_ERROR.defaultMessage(),
            List.of(new FieldErrorBody(exception.getParameterName(), "Required parameter is missing"))
        ));
  }

  @ExceptionHandler(MissingServletRequestPartException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleMissingPart(MissingServletRequestPartException exception) {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(
            ErrorCode.VALIDATION_ERROR.name(),
            ErrorCode.VALIDATION_ERROR.defaultMessage(),
            List.of(new FieldErrorBody(exception.getRequestPartName(), "Required part is missing"))
        ));
  }

  @ExceptionHandler(MaxUploadSizeExceededException.class)
  ResponseEntity<ApiResponseWrapper<Void>> handleMaxUploadSize(MaxUploadSizeExceededException exception) {
    return ResponseEntity.badRequest()
        .body(ApiResponseWrapper.error(ErrorCode.FILE_TOO_LARGE.name(), ErrorCode.FILE_TOO_LARGE.defaultMessage()));
  }
}
