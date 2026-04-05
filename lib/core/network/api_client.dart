import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'auth_token_manager.dart';

/// Http client wrapper using Dio
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  final AuthTokenManager? _tokenManager;

  ApiClient({AuthTokenManager? tokenManager}) : _tokenManager = tokenManager {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.apiTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.apiTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(_logger),
      _AuthInterceptor(_tokenManager),
    ]);
  }

  /// Set auth token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token on logout
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          message: 'Connection timed out. Please try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: error.response?.data?['message'] ??
              'Server error occurred',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ServerException(
          message: 'Request was cancelled',
          statusCode: 499,
        );
      default:
        return const ServerException(
          message: 'Could not connect to server',
          statusCode: 503,
        );
    }
  }
}

/// Logging interceptor for debug mode
class _LoggingInterceptor extends Interceptor {
  final Logger logger;

  _LoggingInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      '← ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      '✗ ${err.response?.statusCode} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}

/// Auth interceptor for token management
class _AuthInterceptor extends Interceptor {
  final AuthTokenManager? _tokenManager;
  final Logger _logger = Logger();

  _AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ✅ SECURITY FIX: Automatically attach valid token to all requests
    if (_tokenManager != null) {
      try {
        final token = await _tokenManager.getValidToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          _logger.d('🔐 [ApiClient] Token attached to ${options.method} ${options.path}');
        }
      } catch (e) {
        _logger.e('❌ [ApiClient] Failed to get token', error: e);
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ SECURITY FIX: Handle 401 - Token expired, refresh and retry
    if (err.response?.statusCode == 401 && _tokenManager != null) {
      _logger.w('🔄 [ApiClient] 401 Unauthorized - Attempting token refresh');
      
      try {
        final newToken = await _tokenManager.forceRefresh();
        
        if (newToken != null) {
          // Retry the request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          
          _logger.i('✅ [ApiClient] Token refreshed, retrying request');
          
          final response = await Dio().request(
            opts.path,
            options: Options(
              method: opts.method,
              headers: opts.headers,
            ),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          
          return handler.resolve(response);
        } else {
          _logger.e('❌ [ApiClient] Token refresh failed - User needs to re-login');
        }
      } catch (e) {
        _logger.e('❌ [ApiClient] Token refresh exception', error: e);
      }
    }
    
    handler.next(err);
  }
}
