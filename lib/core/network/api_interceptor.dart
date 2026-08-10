import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

/// Dio interceptor that handles:
/// - Attaching Bearer tokens to every request
/// - Refreshing tokens on 401 responses
/// - Debug logging of requests/responses
class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  /// Whether a token refresh is currently in progress.
  bool _isRefreshing = false;

  // ──────────────────────────────────────────────
  // Request — attach Bearer token
  // ──────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _secureStorage.read(key: 'access_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    if (kDebugMode) {
      debugPrint('┌── REQUEST ──────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────');
    }

    handler.next(options);
  }

  // ──────────────────────────────────────────────
  // Response — debug logging
  // ──────────────────────────────────────────────

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('┌── RESPONSE ─────────────────────────');
      debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└─────────────────────────────────────');
    }

    handler.next(response);
  }

  // ──────────────────────────────────────────────
  // Error — handle 401 with token refresh
  // ──────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('┌── ERROR ────────────────────────────');
      debugPrint('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('│ Message: ${err.message}');
      debugPrint('└─────────────────────────────────────');
    }

    // If 401 Unauthorized, attempt token refresh
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final accessToken = await _secureStorage.read(key: 'access_token');
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $accessToken';

          final dio = Dio();
          final response = await dio.fetch(options);
          _isRefreshing = false;
          return handler.resolve(response);
        } else {
          // Refresh failed — clear tokens
          await _clearTokens();
          _isRefreshing = false;
        }
      } catch (e) {
        await _clearTokens();
        _isRefreshing = false;
        if (kDebugMode) {
          debugPrint('Token refresh failed: $e');
        }
      }
    }

    handler.next(err);
  }

  // ──────────────────────────────────────────────
  // Token Refresh
  // ──────────────────────────────────────────────

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        ApiConstants.keycloakTokenEndpoint,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          'grant_type': 'refresh_token',
          'client_id': ApiConstants.keycloakClientId,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _secureStorage.write(
          key: 'access_token',
          value: data['access_token'] as String,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: data['refresh_token'] as String,
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Refresh token request failed: $e');
      }
    }

    return false;
  }

  /// Clears all stored tokens.
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'id_token');
  }
}
