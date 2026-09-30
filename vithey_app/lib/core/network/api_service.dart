import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/network/api_response.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';

class ApiService {
  ApiService(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    return _request(() => _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters), fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    return _request(() => _dio.post<Map<String, dynamic>>(path, data: data), fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    return _request(() => _dio.put<Map<String, dynamic>>(path, data: data), fromJson);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    return _request(() => _dio.patch<Map<String, dynamic>>(path, data: data), fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
  }) async {
    return _request(() => _dio.delete<dynamic>(path), fromJson);
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final response = await call();
      final raw = response.data;
      if (raw == null || (raw is String && raw.isEmpty)) {
        return ApiResponse.fromJson({}, fromJson);
      }
      if (raw is Map<String, dynamic>) {
        return ApiResponse.fromJson(raw, fromJson);
      }
      return ApiResponse.fromJson({}, fromJson);
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        return ApiResponse.fromJson(body, fromJson);
      }
      return ApiResponse(
        error: ApiError(
          code: 'NETWORK_ERROR',
          message: error.message ?? 'Network request failed',
        ),
      );
    }
  }
}
