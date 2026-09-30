package com.vithey.auth.util;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponseWrapper<T>(T data, ErrorBody error) {

  public static <T> ApiResponseWrapper<T> success(T data) {
    return new ApiResponseWrapper<>(data, null);
  }

  public static ApiResponseWrapper<Void> error(String code, String message) {
    return new ApiResponseWrapper<>(null, new ErrorBody(code, message, null));
  }

  public static ApiResponseWrapper<Void> error(String code, String message, List<FieldErrorBody> details) {
    return new ApiResponseWrapper<>(null, new ErrorBody(code, message, details));
  }

  public record ErrorBody(String code, String message, List<FieldErrorBody> details) {
  }

  public record FieldErrorBody(String field, String message) {
  }
}
