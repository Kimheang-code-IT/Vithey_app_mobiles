class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final dynamic details;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'Unknown error',
      details: json['details'],
    );
  }
}

class ApiMeta {
  const ApiMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}

class ApiResponse<T> {
  const ApiResponse({this.data, this.meta, this.error});

  final T? data;
  final ApiMeta? meta;
  final ApiError? error;

  bool get isSuccess => error == null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error'] as Map<String, dynamic>) : null,
    );
  }
}
