import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import '../constants/storage_constants.dart';

class DioClient {
  final Dio _dio;
  final LocalStorage _localStorage;

  DioClient(this._dio, this._localStorage) {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(milliseconds: ApiConstants.connectTimeout)
      ..options.receiveTimeout = const Duration(milliseconds: ApiConstants.receiveTimeout)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    // Add interceptors
    _dio.interceptors.add(_getInterceptor());
  }

  Interceptor _getInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests
        final token = await _localStorage.getString(StorageConstants.accessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 (Unauthorized) - Refresh token
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              // Retry the request with new token
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Refresh failed, logout user
            await _localStorage.clear();
          }
        }
        return handler.next(error);
      },
    );
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _localStorage.getString(StorageConstants.refreshToken);
      if (refreshToken == null) return null;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      await _localStorage.setString(StorageConstants.accessToken, newAccessToken);

      return newAccessToken;
    } catch (e) {
      return null;
    }
  }

  // HTTP Methods
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(url, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(url, data: data, queryParameters: queryParameters, options: options);
  }
}
