package com.vithey.profile.util;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponseWrapper<T>(T data, Meta meta, ErrorBody error) {

  public static <T> ApiResponseWrapper<T> success(T data) {
    return new ApiResponseWrapper<>(data, null, null);
  }

  public static <T> ApiResponseWrapper<T> paginated(T data, Meta meta) {
    return new ApiResponseWrapper<>(data, meta, null);
  }

  public static ApiResponseWrapper<Void> error(String code, String message) {
    return new ApiResponseWrapper<>(null, null, new ErrorBody(code, message, null));
  }

  public static ApiResponseWrapper<Void> error(String code, String message, List<FieldErrorBody> details) {
    return new ApiResponseWrapper<>(null, null, new ErrorBody(code, message, details));
  }

  public record Meta(int page, int limit, long total, int totalPages) {
  }

  public record ErrorBody(String code, String message, List<FieldErrorBody> details) {
  }

  public record FieldErrorBody(String field, String message) {
  }
}
