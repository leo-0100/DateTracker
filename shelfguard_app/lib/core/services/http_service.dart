import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

/// HTTP service with HTTPS enforcement and security headers
class HttpService {
  late final Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  HttpService() {
    _dio = Dio(_getBaseOptions());
    _setupInterceptors();
  }

  BaseOptions _getBaseOptions() {
    return BaseOptions(
      // In production, replace with your actual API base URL
      baseUrl: 'https://api.shelfguard.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),

      // Security headers
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      // Force HTTPS only
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token to requests
          final token = await _secureStorage.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Security headers
          options.headers['X-Content-Type-Options'] = 'nosniff';
          options.headers['X-Frame-Options'] = 'DENY';
          options.headers['X-XSS-Protection'] = '1; mode=block';
          options.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains';

          // Ensure HTTPS only
          if (!options.uri.isScheme('HTTPS')) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Only HTTPS connections are allowed',
                type: DioExceptionType.badResponse,
              ),
            );
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Validate response
          if (response.statusCode == 401) {
            // Token expired, clear auth data
            _secureStorage.clearAll();
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Handle specific errors
          if (error.response?.statusCode == 401) {
            // Unauthorized, clear tokens
            await _secureStorage.clearAll();
          }

          // Log error for debugging (in production, use proper logging service)
          print('HTTP Error: ${error.message}');

          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor for development (remove in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[HTTP] $obj'),
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
