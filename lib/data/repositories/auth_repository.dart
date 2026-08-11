import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/local/dummy_data.dart';

/// Repository handling all authentication operations via Keycloak OAuth 2.0.
///
/// Uses [FlutterAppAuth] for the Authorization Code flow and
/// [FlutterSecureStorage] for secure token persistence.
///
/// When [ApiConstants.useMockApi] is enabled, the OAuth flow is bypassed and
/// a locally-generated, non-expired JWT is stored instead — so auth state
/// checks ([isAuthenticated], [getUserRoles], etc.) continue to work without
/// a running Keycloak server.
class AuthRepository {
  AuthRepository({
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? secureStorage,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;

  // ──────────────────────────────────────────────
  // Storage Keys
  // ──────────────────────────────────────────────

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';

  // ──────────────────────────────────────────────
  // Login — triggers Keycloak OAuth flow
  // ──────────────────────────────────────────────

  /// Initiates the Keycloak OAuth 2.0 Authorization Code flow.
  ///
  /// Opens the system browser for Keycloak login, then handles the
  /// callback and stores the returned tokens.
  /// Returns `true` if login was successful.
  ///
  /// When [ApiConstants.useMockApi] is enabled, bypasses OAuth and stores a
  /// dummy JWT instead.
  Future<bool> login() async {
    if (ApiConstants.useMockApi) {
      await _storeDummyTokens();
      return true;
    }

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          ApiConstants.keycloakClientId,
          ApiConstants.keycloakRedirectUri,
          issuer: ApiConstants.keycloakIssuer,
          scopes: ['openid', 'profile', 'email'],
          promptValues: ['login'],
        ),
      );

      if (result != null) {
        await _storeTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login failed: $e');
      }
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Handle Callback — exchange code for tokens
  // ──────────────────────────────────────────────

  /// Exchanges an authorization code for tokens.
  ///
  /// Used when handling the OAuth callback manually.
  ///
  /// When [ApiConstants.useMockApi] is enabled, stores a dummy JWT and
  /// returns `true`.
  Future<bool> handleCallback(String authorizationCode) async {
    if (ApiConstants.useMockApi) {
      await _storeDummyTokens();
      return true;
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.authCallback,
        data: {'code': authorizationCode},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storeTokens(
          accessToken: data['access_token'] as String?,
          refreshToken: data['refresh_token'] as String?,
          idToken: data['id_token'] as String?,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Callback handling failed: $e');
      }
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────

  /// Clears all stored tokens and calls backend logout.
  ///
  /// When [ApiConstants.useMockApi] is enabled, only local tokens are cleared
  /// (no backend call).
  Future<void> logout() async {
    if (ApiConstants.useMockApi) {
      await _clearTokens();
      return;
    }

    try {
      final idToken = await _secureStorage.read(key: _idTokenKey);

      // Call backend logout endpoint
      await DioClient.instance.post(
        ApiConstants.authLogout,
        data: {'id_token': idToken},
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Backend logout call failed: $e');
      }
    } finally {
      // Always clear local tokens
      await _clearTokens();
    }
  }

  // ──────────────────────────────────────────────
  // Token Refresh
  // ──────────────────────────────────────────────

  /// Refreshes the access token using the stored refresh token.
  /// Returns `true` if refresh was successful.
  ///
  /// When [ApiConstants.useMockApi] is enabled, ensures a dummy JWT is present
  /// and returns `true`.
  Future<bool> refreshToken() async {
    if (ApiConstants.useMockApi) {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty) return true;
      await _storeDummyTokens();
      return true;
    }

    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final result = await _appAuth.token(
        TokenRequest(
          ApiConstants.keycloakClientId,
          ApiConstants.keycloakRedirectUri,
          issuer: ApiConstants.keycloakIssuer,
          refreshToken: refreshToken,
          grantType: 'refresh_token',
        ),
      );

      if (result != null) {
        await _storeTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Token refresh failed: $e');
      }
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Token Accessors
  // ──────────────────────────────────────────────

  /// Returns the stored access token, or `null` if none exists.
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Extracts user roles from the JWT access token.
  ///
  /// Looks for `realm_access.roles` in the token claims.
  /// Returns an empty list if the token is missing or invalid.
  Future<List<String>> getUserRoles() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return [];

      final decodedToken = JwtDecoder.decode(token);
      final realmAccess = decodedToken['realm_access'] as Map<String, dynamic>?;
      if (realmAccess == null) return [];

      final roles = realmAccess['roles'] as List<dynamic>?;
      return roles?.map((r) => r.toString()).toList() ?? [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to extract roles: $e');
      }
      return [];
    }
  }

  /// Extracts the current user's ID (`sub` claim) from the JWT.
  Future<String?> getCurrentUserId() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return null;

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to extract user ID: $e');
      }
      return null;
    }
  }

  /// Extracts the user's email from the JWT.
  Future<String?> getUserEmail() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return null;

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Extracts the user's name from the JWT.
  Future<String?> getUserName() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return null;

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['name'] as String? ??
          decodedToken['preferred_username'] as String?;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // Auth State Checks
  // ──────────────────────────────────────────────

  /// Returns `true` if a valid (non-expired) access token exists.
  Future<bool> isAuthenticated() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return false;

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  /// Checks if the user has a specific role.
  Future<bool> hasRole(String role) async {
    final roles = await getUserRoles();
    return roles.contains(role);
  }

  // ──────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────

  Future<void> _storeTokens({
    String? accessToken,
    String? refreshToken,
    String? idToken,
  }) async {
    if (accessToken != null) {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    }
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: idToken);
    }
  }

  /// Stores a dummy JWT in every token slot so that all token-reading
  /// accessors and auth-state checks return valid data.
  Future<void> _storeDummyTokens() async {
    final token = DummyData.instance.generateJwt();
    await _storeTokens(
      accessToken: token,
      refreshToken: token,
      idToken: token,
    );
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _idTokenKey);
  }
}
