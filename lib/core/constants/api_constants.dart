/// Centralized API endpoint constants and Keycloak configuration.
///
/// All backend URLs are defined here so they can be changed in one place.
/// The Spring Boot API runs at [baseUrl] and Keycloak at [keycloakBaseUrl].
class ApiConstants {
  ApiConstants._();

  // ──────────────────────────────────────────────
  // Base URLs
  // ──────────────────────────────────────────────

  /// Spring Boot REST API base URL.
  static const String baseUrl = 'http://localhost:8080/api/v1';

  /// Keycloak authentication server base URL.
  static const String keycloakBaseUrl = 'http://localhost:8090';

  // ──────────────────────────────────────────────
  // Keycloak Configuration
  // ──────────────────────────────────────────────

  static const String keycloakRealm = 'market-realm';
  static const String keycloakClientId = 'spring-boot-api';
  static const String keycloakRedirectUri = 'com.nestify.app://callback';

  /// Keycloak authorization endpoint.
  static String get keycloakAuthEndpoint =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/auth';

  /// Keycloak token endpoint.
  static String get keycloakTokenEndpoint =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/token';

  /// Keycloak end-session (logout) endpoint.
  static String get keycloakLogoutEndpoint =>
      '$keycloakBaseUrl/realms/$keycloakRealm/protocol/openid-connect/logout';

  /// Keycloak issuer URL (for discovery).
  static String get keycloakIssuer => '$keycloakBaseUrl/realms/$keycloakRealm';

  // ──────────────────────────────────────────────
  // Auth Endpoints
  // ──────────────────────────────────────────────

  static const String authCallback = '/auth/callback';
  static const String authLogout = '/auth/logout';
  static const String authResetPassword = '/auth/reset-password';
  static const String authTokenFunctions = '/auth/token-functions';

  // ──────────────────────────────────────────────
  // User Endpoints
  // ──────────────────────────────────────────────

  static const String usersRegister = '/users/register';
  static const String usersById = '/users/by-id';
  static const String usersData = '/users/data';
  static const String usersUpdate = '/users/update-user-data';
  static const String usersBookingCount = '/users/booking-count-with-id';

  // ──────────────────────────────────────────────
  // Provider Endpoints
  // ──────────────────────────────────────────────

  static const String providerPersist = '/provider/persist';
  static const String providerAll = '/provider/all';
  static const String providerById = '/provider/with-id'; // + /{id}
  static const String providerPopular = '/api/v1/providers/top5';
  static const String providerCount = '/provider/count';

  // ──────────────────────────────────────────────
  // Service Gig Endpoints
  // ──────────────────────────────────────────────

  static const String gigCreate = '/gig';
  static const String gigActiveGigs = '/gig/active-gigs';
  static const String gigAllGigs = '/gig/all-gigs';
  static const String gigById = '/gig/by-id'; // + /{id}
  static const String gigAverageRating = '/gig/average-rating';
  static const String gigActiveCount = '/gig/count-of-active-gigs';

  // ──────────────────────────────────────────────
  // Booking Endpoints
  // ──────────────────────────────────────────────

  static const String bookingPersist = '/booking/persist';
  static const String bookingByClientId = '/booking/by-client-id';
  static const String bookingCancel = '/booking/cancel';
  static const String bookingReschedule = '/booking/reschedule';
  static const String bookingMarkComplete = '/booking/mark-complete';

  // ──────────────────────────────────────────────
  // Review Endpoints
  // ──────────────────────────────────────────────

  static const String reviewByGigId = '/review/by-gig-id';
  static const String reviewAdd = '/review/add-review';

  // ──────────────────────────────────────────────
  // Category Endpoints
  // ──────────────────────────────────────────────

  static const String categoryAll = '/category/all';
  static const String categoryAdd = '/category/add';
}
