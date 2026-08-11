import 'dart:convert';

import '../../models/booking_dto.dart';
import '../../models/category_dto.dart';
import '../../models/provider_dto.dart';
import '../../models/review_dto.dart';
import '../../models/service_gig_dto.dart';
import '../../models/user_dto.dart';

/// In-memory dummy data provider.
///
/// When [ApiConstants.useMockApi] is `true`, every repository delegates to this
/// singleton instead of hitting the Spring Boot REST API. The data is realistic
/// and internally consistent: gigs reference real providers and categories,
/// bookings reference real providers and gigs, and reviews reference real
/// users and gigs.
///
/// A number of operations are **mutable** so the UI responds to actions:
/// - cancelling / completing / rescheduling a booking
/// - adding a review
/// - creating a gig / booking
///
/// Mutations are tracked with small override maps so the immutable DTOs stay
/// untouched while callers always see the latest state.
class DummyData {
  DummyData._() {
    _buildDefaults();
  }

  /// Singleton access.
  static final DummyData instance = DummyData._();

  // ──────────────────────────────────────────────
  // Auth — dummy JWT
  // ──────────────────────────────────────────────

  /// The user id embedded in the dummy JWT.
  static const String dummyUserId = 'dummy-user-001';

  /// The user email embedded in the dummy JWT.
  static const String dummyUserEmail = 'alex.johnson@example.com';

  /// The user display name embedded in the dummy JWT.
  static const String dummyUserName = 'Alex Johnson';

  /// Builds a non-expired, unsigned JWT whose payload carries the user id,
  /// email, name, and the `user` role under `realm_access.roles`.
  ///
  /// [jwt_decoder] only reads claims (it never verifies the signature), so a
  /// hand-built token is sufficient to satisfy
  /// [AuthRepository.isAuthenticated] and [AuthRepository.getUserRoles].
  String generateJwt() {
    final header =
        base64UrlEncode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));

    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = <String, dynamic>{
      'sub': dummyUserId,
      'email': dummyUserEmail,
      'name': dummyUserName,
      'preferred_username': 'alex_johnson',
      'realm_access': <String, dynamic>{
        'roles': <String>['user'],
      },
      'exp': nowSeconds + _oneYearSeconds,
      'iat': nowSeconds,
      'iss': 'http://localhost:8090/realms/market-realm',
      'aud': 'spring-boot-api',
    };

    final payloadB64 =
        base64UrlEncode(utf8.encode(jsonEncode(payload)));
    // Signature is irrelevant — jwt_decoder does not verify it.
    return '$header.$payloadB64.dummy-signature';
  }

  static const int _oneYearSeconds = 365 * 24 * 60 * 60;

  // ──────────────────────────────────────────────
  // Categories
  // ──────────────────────────────────────────────

  final List<CategoryResponseDto> _categories = [];

  /// All service categories.
  List<CategoryResponseDto> get categories =>
      List<CategoryResponseDto>.unmodifiable(_categories);

  CategoryResponseDto? categoryById(String id) =>
      _firstWhere(_categories, (c) => c.id == id);

  // ──────────────────────────────────────────────
  // Providers
  // ──────────────────────────────────────────────

  final List<ProviderDto> _providerDtos = [];
  final List<ProviderWithCategory> _providers = [];

  /// All providers with their categories and review metadata.
  List<ProviderWithCategory> get providers =>
      List<ProviderWithCategory>.unmodifiable(_providers);

  /// A small slice of the highest-rated providers for the home screen.
  List<ProviderWithCategory> get popularProviders =>
      _providers.where((p) => p.avgRate >= 4.5).take(4).toList();

  /// Paginated slice of providers for the providers list.
  List<ProviderWithCategory> providersPage({int page = 0, int size = 10}) {
    final start = (page * size).clamp(0, _providers.length);
    final end = (start + size).clamp(0, _providers.length);
    return _providers.sublist(start, end);
  }

  int get providerCount => _providers.length;

  int providersTotalPages({int size = 10}) =>
      (providerCount == 0 ? 1 : (providerCount / size).ceil());

  ProviderWithCategory? providerById(String id) =>
      _firstWhere(_providers, (p) => p.providerDto.id == id);

  ProviderDto? providerDtoById(String id) =>
      _firstWhere(_providerDtos, (p) => p.id == id);

  /// Registers a new provider from raw registration data.
  ProviderDto registerProvider(Map<String, dynamic> data) {
    final id = 'prov-${DateTime.now().millisecondsSinceEpoch}';
    final dto = ProviderDto(
      id: id,
      userName: data['username'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      email: data['email'] as String?,
      contactNo: data['contactNo'] as String?,
      expertise: 'New Professional',
      isVerified: false,
      address: data['address'] as String?,
      experience: '0 years',
      jobCount: 0,
      shortDescription: 'Recently joined the platform.',
    );
    _providerDtos.add(dto);
    return dto;
  }

  // ──────────────────────────────────────────────
  // Gigs
  // ──────────────────────────────────────────────

  final List<ServiceGigResponseDto> _gigs = [];

  /// All active service gigs.
  List<ServiceGigResponseDto> get gigs =>
      List<ServiceGigResponseDto>.unmodifiable(_gigs);

  /// Active gigs filtered by search [query] and/or [categoryId].
  List<ServiceGigResponseDto> activeGigs({
    int page = 0,
    int size = 10,
    String? query,
    String? categoryId,
  }) {
    var filtered = _gigs.where((g) => g.isActive).toList();

    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((g) => g.category?.id == categoryId).toList();
    }

    final search = query?.trim() ?? '';
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      filtered = filtered.where((g) {
        return g.title.toLowerCase().contains(q) ||
            (g.description?.toLowerCase().contains(q) ?? false) ||
            (g.serviceLocation?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    final total = filtered.length;
    final start = (page * size).clamp(0, total);
    final end = (start + size).clamp(0, total);
    return filtered.sublist(start, end);
  }

  int activeGigsTotalPages({
    int size = 10,
    String? query,
    String? categoryId,
  }) {
    final count = activeGigs(query: query, categoryId: categoryId, size: 1 << 30)
        .length;
    return count == 0 ? 1 : (count / size).ceil();
  }

  ServiceGigResponseDto? gigById(String id) =>
      _firstWhere(_gigs, (g) => g.id == id);

  /// Average review rating for a gig (0.0–5.0).
  ///
  /// Reviews are associated with the gig's provider, so the rating is
  /// computed from all reviews for that provider.
  double averageRating(String gigId) {
    final reviews = reviewsByGigId(gigId);
    if (reviews.isNotEmpty) {
      final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
      return total / reviews.length;
    }

    // Fall back to the provider's overall average rating.
    final gig = gigById(gigId);
    if (gig == null || gig.provider == null) return 0.0;
    return _providerAvgRating(gig.provider!.id);
  }

  /// Convenience: total count of active gigs.
  int get activeGigCount => _gigs.where((g) => g.isActive).length;

  /// Convenience: all gigs (active + inactive).
  List<ServiceGigResponseDto> get allGigs =>
      List<ServiceGigResponseDto>.unmodifiable(_gigs);

  /// Creates a new gig from a [ServiceGigDto] and returns the full
  /// response DTO.
  ///
  /// The request DTO does not carry a provider or category, so the new
  /// gig defaults to the first category and an unset provider.
  ServiceGigResponseDto createGig(ServiceGigDto gig) {
    final id = 'gig-${DateTime.now().millisecondsSinceEpoch}';
    final category = _categories.isNotEmpty ? _categories.first : null;
    final response = ServiceGigResponseDto(
      id: id,
      title: gig.title,
      serviceLocation: gig.shortDescription,
      description: gig.fullDescription,
      basePrice: gig.basePrice,
      priceType: gig.priceType,
      totalBookingCount: 0,
      currency: gig.currency,
      isActive: gig.isActive,
      createdAt: gig.createdAt ?? DateTime.now(),
      updatedAt: gig.updatedAt ?? DateTime.now(),
      provider: null,
      category: category,
    );
    _gigs.add(response);
    return response;
  }

  // ──────────────────────────────────────────────
  // Reviews
  // ──────────────────────────────────────────────

  final List<ReviewDto> _reviews = [];

  /// Map from review id → gig id (for rating lookups on gigs).
  final Map<String, String> _reviewGigIds = {};

  /// Reviews for the gig identified by [gigId].
  List<ReviewDto> reviewsByGigId(String gigId) {
    final gig = gigById(gigId);
    if (gig == null || gig.provider == null) return [];

    // Reviews are modelled per-provider; attach the provider's reviews to
    // any gig that belongs to that provider.
    return _reviews
        .where(
          (r) =>
              r.id != null &&
              _reviewGigIds[r.id] == gigId,
        )
        .toList();
  }

  /// Reviews associated with a provider (used by the provider detail screen
  /// if needed).
  List<ReviewDto> reviewsByProvider(String providerId) => _reviews
      .where((r) => _reviewProviderIds[r.id] == providerId)
      .toList();

  /// Provider ids keyed by review id.
  final Map<String, String> _reviewProviderIds = {};

  double _providerAvgRating(String providerId) {
    final providerReviews = reviewsByProvider(providerId);
    if (providerReviews.isEmpty) return 0.0;
    final total =
        providerReviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / providerReviews.length;
  }

  /// Adds a review and returns the created DTO.
  ReviewDto addReview(ReviewRequestDto review) {
    final id = 'rev-${DateTime.now().millisecondsSinceEpoch}-${_reviews.length}';
    final dto = ReviewDto(
      id: id,
      rating: review.rating,
      comment: review.comment,
      providerResponse: '',
      reviewsClient: UserDto(
        id: _currentUser.id,
        firstName: _currentUser.firstName,
        lastName: _currentUser.lastName,
        username: _currentUser.username,
        email: _currentUser.email,
      ),
      createdAt: DateTime.now(),
    );
    _reviews.add(dto);
    _reviewGigIds[id] = review.serviceGigId ?? '';
    _reviewProviderIds[id] = review.providerId;
    return dto;
  }

  // ──────────────────────────────────────────────
  // Bookings
  // ──────────────────────────────────────────────

  final List<BookingResponseDto> _bookings = [];

  /// All bookings belonging to the current dummy user, reflecting any
  /// in-memory status/date/time overrides.
  List<BookingResponseDto> get bookingsByClient => getBookingsByClient();

  /// In-memory mutation state so cancel/complete/reschedule are reflected.
  final Map<String, String> _bookingStatus = {};
  final Map<String, String> _bookingDate = {};
  final Map<String, String> _bookingTime = {};

  BookingResponseDto _applyOverrides(BookingResponseDto booking) {
    final status = _bookingStatus[booking.id] ?? booking.status;
    final date = _bookingDate[booking.id];
    final time = _bookingTime[booking.id];
    if (status == booking.status && date == null && time == null) {
      return booking;
    }
    return BookingResponseDto(
      id: booking.id,
      name: booking.name,
      email: booking.email,
      contactNo: booking.contactNo,
      address: booking.address,
      additionalInformation: booking.additionalInformation,
      status: status,
      startingTime: time ?? booking.startingTime,
      startingDate: date ?? booking.startingDate,
      providerDto: booking.providerDto,
      serviceGigResponseDto: booking.serviceGigResponseDto,
    );
  }

  List<BookingResponseDto> getBookingsByClient() =>
      _bookings.map(_applyOverrides).toList();

  /// Creates a booking from a request and returns the response DTO.
  BookingResponseDto createBooking(BookingRequestDto booking) {
    final id = 'bk-${DateTime.now().millisecondsSinceEpoch}-${_bookings.length}';
    final provider = providerDtoById(booking.providerId);
    final gig = gigById(booking.gigId);
    final response = BookingResponseDto(
      id: id,
      name: booking.name,
      email: booking.email,
      contactNo: booking.contactNo,
      address: booking.address,
      additionalInformation: booking.additionalInformation,
      status: booking.status,
      startingTime: booking.startingTime,
      startingDate: booking.startingDate,
      providerDto: provider,
      serviceGigResponseDto: gig,
    );
    _bookings.add(response);
    return response;
  }

  bool cancelBooking(String bookingId) {
    if (_bookings.any((b) => b.id == bookingId)) {
      _bookingStatus[bookingId] = 'cancelled';
      return true;
    }
    return false;
  }

  bool markComplete(String bookingId) {
    if (_bookings.any((b) => b.id == bookingId)) {
      _bookingStatus[bookingId] = 'completed';
      return true;
    }
    return false;
  }

  bool rescheduleBooking(String bookingId, String date, String time) {
    if (_bookings.any((b) => b.id == bookingId)) {
      _bookingDate[bookingId] = date;
      _bookingTime[bookingId] = time;
      return true;
    }
    return false;
  }

  // ──────────────────────────────────────────────
  // Users
  // ──────────────────────────────────────────────

  late final UserResponseDto _currentUser;

  UserResponseDto get currentUser => _currentUser;

  final List<UserResponseDto> _users = [];

  UserResponseDto? userById(String id) =>
      _firstWhere(_users, (u) => u.id == id);

  /// Persists an updated user profile (in place).
  UserResponseDto updateUser(UserResponseDto user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
    if (user.id == _currentUser.id) {
      _currentUser = user;
    }
    return user;
  }

  int bookingCount(String userId) {
    // The dummy user owns every booking in scope.
    return _bookings.length;
  }

  // ──────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────

  T? _firstWhere<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Builds the default data set once.
  void _buildDefaults() {
    _buildCategories();
    _buildProviders();
    _buildUsers();
    _buildGigs();
    _buildBookings();
    _buildReviews();
  }

  void _buildCategories() {
    _categories
      ..add(const CategoryResponseDto(id: 'cat-1', name: 'Maintenance'))
      ..add(const CategoryResponseDto(id: 'cat-2', name: 'Renovation'))
      ..add(const CategoryResponseDto(id: 'cat-3', name: 'Cleaning'))
      ..add(const CategoryResponseDto(id: 'cat-4', name: 'Electrical'))
      ..add(const CategoryResponseDto(id: 'cat-5', name: 'Plumbing'))
      ..add(const CategoryResponseDto(id: 'cat-6', name: 'Gardening'))
      ..add(const CategoryResponseDto(id: 'cat-7', name: 'Painting'))
      ..add(const CategoryResponseDto(id: 'cat-8', name: 'IT Support'));
  }

  void _buildProviders() {
    final p1 = ProviderDto(
      id: 'prov-1',
      userName: 'mike_repair',
      firstName: 'Mike',
      lastName: 'Rodriguez',
      email: 'mike.rodriguez@example.com',
      contactNo: '+1 (555) 123-4567',
      expertise: 'General Maintenance & Repairs',
      isVerified: true,
      address: '120 Oak Street, San Francisco, CA',
      experience: '8 years',
      jobCount: 342,
      shortDescription:
          'Reliable handyman with 8+ years handling everything from minor '
          'repairs to full home maintenance. Licensed and insured.',
    );
    final p2 = ProviderDto(
      id: 'prov-2',
      userName: 'sarah_clean',
      firstName: 'Sarah',
      lastName: 'Chen',
      email: 'sarah.chen@example.com',
      contactNo: '+1 (555) 234-5678',
      expertise: 'Deep Cleaning & Sanitization',
      isVerified: true,
      address: '45 Maple Ave, Portland, OR',
      experience: '5 years',
      jobCount: 287,
      shortDescription:
          'Detail-oriented cleaning specialist offering residential and '
          'commercial deep cleans with eco-friendly products.',
    );
    final p3 = ProviderDto(
      id: 'prov-3',
      userName: 'david_renovate',
      firstName: 'David',
      lastName: 'Kumar',
      email: 'david.kumar@example.com',
      contactNo: '+1 (555) 345-6789',
      expertise: 'Kitchen & Bath Remodeling',
      isVerified: true,
      address: '78 Pine Road, Austin, TX',
      experience: '12 years',
      jobCount: 156,
      shortDescription:
          'Master craftsman specializing in kitchen and bathroom renovations '
          'with a focus on modern, functional designs.',
    );
    final p4 = ProviderDto(
      id: 'prov-4',
      userName: 'elena_plumb',
      firstName: 'Elena',
      lastName: 'Volkov',
      email: 'elena.volkov@example.com',
      contactNo: '+1 (555) 456-7890',
      expertise: 'Plumbing & Pipe Fitting',
      isVerified: true,
      address: '33 Cedar Ln, Denver, CO',
      experience: '9 years',
      jobCount: 218,
      shortDescription:
          'Certified plumber handling leaky faucets to full bathroom installs. '
          '24/7 emergency service available.',
    );
    final p5 = ProviderDto(
      id: 'prov-5',
      userName: 'james_electric',
      firstName: 'James',
      lastName: 'Okafor',
      email: 'james.okafor@example.com',
      contactNo: '+1 (555) 567-8901',
      expertise: 'Electrical Installation & Repair',
      isVerified: false,
      address: '88 Spruce St, Atlanta, GA',
      experience: '7 years',
      jobCount: 134,
      shortDescription:
          'Licensed electrician for residential wiring, panel upgrades, and '
          'lighting installations.',
    );
    final p6 = ProviderDto(
      id: 'prov-6',
      userName: 'liam_garden',
      firstName: 'Liam',
      lastName: 'Nguyen',
      email: 'liam.nguyen@example.com',
      contactNo: '+1 (555) 678-9012',
      expertise: 'Landscape & Garden Care',
      isVerified: true,
      address: '200 Willow Way, Seattle, WA',
      experience: '6 years',
      jobCount: 98,
      shortDescription:
          'Passionate landscape designer turning outdoor spaces into serene '
          'gardens. Seasonal maintenance packages available.',
    );

    _providerDtos.addAll([p1, p2, p3, p4, p5, p6]);

    final catMaintenance = _categories.firstWhere((c) => c.id == 'cat-1');
    final catRenovation = _categories.firstWhere((c) => c.id == 'cat-2');
    final catCleaning = _categories.firstWhere((c) => c.id == 'cat-3');
    final catElectrical = _categories.firstWhere((c) => c.id == 'cat-4');
    final catPlumbing = _categories.firstWhere((c) => c.id == 'cat-5');
    final catGardening = _categories.firstWhere((c) => c.id == 'cat-6');

    _providers
      ..add(ProviderWithCategory(
        providerDto: p1,
        categoriesSet: [catMaintenance, catElectrical],
        reviews: 87,
        avgRate: 4.8,
      ))
      ..add(ProviderWithCategory(
        providerDto: p2,
        categoriesSet: [catCleaning],
        reviews: 124,
        avgRate: 4.9,
      ))
      ..add(ProviderWithCategory(
        providerDto: p3,
        categoriesSet: [catRenovation, catPlumbing],
        reviews: 63,
        avgRate: 4.7,
      ))
      ..add(ProviderWithCategory(
        providerDto: p4,
        categoriesSet: [catPlumbing, catMaintenance],
        reviews: 92,
        avgRate: 4.6,
      ))
      ..add(ProviderWithCategory(
        providerDto: p5,
        categoriesSet: [catElectrical, catMaintenance],
        reviews: 41,
        avgRate: 4.3,
      ))
      ..add(ProviderWithCategory(
        providerDto: p6,
        categoriesSet: [catGardening],
        reviews: 55,
        avgRate: 4.5,
      ));
  }

  void _buildUsers() {
    _users
      ..add(UserResponseDto(
        id: dummyUserId,
        address: '101 First Street, San Francisco, CA',
        contact: '+1 (555) 987-6543',
        email: dummyUserEmail,
        paymentMethod: 'Credit Card',
        firstName: 'Alex',
        lastName: 'Johnson',
        username: 'alex_johnson',
        createdAt: '2023-06-15T10:30:00Z',
      ))
      ..add(const UserResponseDto(
        id: 'user-002',
        address: '202 Second Ave, Brooklyn, NY',
        contact: '+1 (555) 222-3333',
        email: 'maria.santos@example.com',
        paymentMethod: 'PayPal',
        firstName: 'Maria',
        lastName: 'Santos',
        username: 'maria_s',
        createdAt: '2024-01-20T14:00:00Z',
      ));

    _currentUser = _users.first;
  }

  void _buildGigs() {
    final maint = categoryById('cat-1')!; // Maintenance
    final renov = categoryById('cat-2')!; // Renovation
    final clean = categoryById('cat-3')!; // Cleaning
    final electr = categoryById('cat-4')!; // Electrical
    final plumb = categoryById('cat-5')!; // Plumbing
    final garden = categoryById('cat-6')!; // Gardening

    _gigs
      ..add(ServiceGigResponseDto(
        id: 'gig-1',
        title: 'General Home Maintenance',
        serviceLocation: 'On-site at your home',
        description:
            'Full-service maintenance including door adjustments, fixture '
            'repairs, furniture assembly, and general upkeep for your home '
            'or office.',
        basePrice: 75,
        priceType: 'Hourly',
        totalBookingCount: 128,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2023, 8, 12),
        updatedAt: DateTime(2024, 2, 3),
        provider: providerDtoById('prov-1'),
        category: maint,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-2',
        title: 'Deep House Cleaning',
        serviceLocation: 'On-site at your home',
        description:
            'Thorough cleaning of kitchen, bathrooms, living areas, and '
            'bedrooms. Includes dusting, vacuuming, mopping, and surface '
            'sanitization using eco-friendly products.',
        basePrice: 150,
        priceType: 'Per Job',
        totalBookingCount: 204,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2023, 9, 5),
        updatedAt: DateTime(2024, 1, 18),
        provider: providerDtoById('prov-2'),
        category: clean,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-3',
        title: 'Kitchen & Bathroom Remodel',
        serviceLocation: 'On-site at your home',
        description:
            'Complete kitchen or bathroom renovation from layout planning to '
            'final installation. Cabinets, countertops, tiles, plumbing, and '
            'electrical work included.',
        basePrice: 450,
        priceType: 'Per Day',
        totalBookingCount: 76,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2023, 10, 21),
        updatedAt: DateTime(2024, 3, 11),
        provider: providerDtoById('prov-3'),
        category: renov,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-4',
        title: 'Plumbing Inspection & Repair',
        serviceLocation: 'On-site at your home',
        description:
            'Comprehensive plumbing inspection followed by repair of leaks, '
            'clogs, running toilets, and fixture replacements. Upfront pricing.',
        basePrice: 95,
        priceType: 'Hourly',
        totalBookingCount: 142,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2023, 11, 2),
        updatedAt: DateTime(2024, 2, 28),
        provider: providerDtoById('prov-4'),
        category: plumb,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-5',
        title: 'Light Fixture & Outlet Installation',
        serviceLocation: 'On-site at your home',
        description:
            'Installation of light fixtures, ceiling fans, outlets, switches, '
            'and dimmer controls. Includes safety inspection and cleanup.',
        basePrice: 85,
        priceType: 'Per Job',
        totalBookingCount: 98,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2023, 12, 14),
        updatedAt: DateTime(2024, 4, 1),
        provider: providerDtoById('prov-5'),
        category: electr,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-6',
        title: 'Lawn Care & Garden Maintenance',
        serviceLocation: 'On-site at your home',
        description:
            'Weekly or bi-weekly lawn mowing, edging, trimming, fertilizing, '
            'and seasonal cleanup. Monthly plans available.',
        basePrice: 60,
        priceType: 'Hourly',
        totalBookingCount: 67,
        currency: 'USD',
        isActive: true,
        createdAt: DateTime(2024, 1, 9),
        updatedAt: DateTime(2024, 3, 22),
        provider: providerDtoById('prov-6'),
        category: garden,
      ))
      ..add(ServiceGigResponseDto(
        id: 'gig-7',
        title: 'Furniture Assembly',
        serviceLocation: 'On-site at your home',
        description:
            'Professional assembly of IKEA, Wayfair, and other flat-pack '
            'furniture. Beds, shelves, desks, and storage units. Tools provided.',
        basePrice: 65,
        priceType: 'Per Job',
        totalBookingCount: 89,
        currency: 'USD',
        isActive: false,
        createdAt: DateTime(2023, 7, 18),
        updatedAt: DateTime(2024, 1, 30),
        provider: providerDtoById('prov-1'),
        category: maint,
      ));
  }

  void _buildBookings() {
    final gig1 = _gigs.firstWhere((g) => g.id == 'gig-1');
    final gig3 = _gigs.firstWhere((g) => g.id == 'gig-3');
    final gig4 = _gigs.firstWhere((g) => g.id == 'gig-4');
    final prov1 = _providers.firstWhere((p) => p.providerDto.id == 'prov-1');
    final prov3 = _providers.firstWhere((p) => p.providerDto.id == 'prov-3');
    final prov4 = _providers.firstWhere((p) => p.providerDto.id == 'prov-4');

    _bookings
      ..add(BookingResponseDto(
        id: 'bk-1001',
        name: 'Alex Johnson',
        email: dummyUserEmail,
        contactNo: '+1 (555) 987-6543',
        address: '101 First Street, San Francisco, CA',
        additionalInformation: 'Please bring a ladder for upper shelf work.',
        status: 'pending',
        startingTime: '09:00 AM',
        startingDate: '2024-05-20',
        providerDto: prov1.providerDto,
        serviceGigResponseDto: gig1,
      ))
      ..add(BookingResponseDto(
        id: 'bk-1002',
        name: 'Alex Johnson',
        email: dummyUserEmail,
        contactNo: '+1 (555) 987-6543',
        address: '101 First Street, San Francisco, CA',
        additionalInformation: null,
        status: 'completed',
        startingTime: '10:30 AM',
        startingDate: '2024-04-12',
        providerDto: prov3.providerDto,
        serviceGigResponseDto: gig3,
      ))
      ..add(BookingResponseDto(
        id: 'bk-1003',
        name: 'Alex Johnson',
        email: dummyUserEmail,
        contactNo: '+1 (555) 987-6543',
        address: '101 First Street, San Francisco, CA',
        additionalInformation: 'Gate code: 4821#',
        status: 'cancelled',
        startingTime: '02:00 PM',
        startingDate: '2024-05-05',
        providerDto: prov4.providerDto,
        serviceGigResponseDto: gig4,
      ));
  }

  void _buildReviews() {
    // Reviews are associated with prov-2 (gig-2).
    final maria = UserDto(
      id: 'user-002',
      firstName: 'Maria',
      lastName: 'Santos',
      username: 'maria_s',
      email: 'maria.santos@example.com',
    );
    final alex = UserDto(
      id: dummyUserId,
      firstName: _currentUser.firstName,
      lastName: _currentUser.lastName,
      username: _currentUser.username,
      email: _currentUser.email,
    );

    _reviews
      ..add(ReviewDto(
        id: 'rev-1',
        rating: 5,
        comment:
            'Sarah and her team did an outstanding job. The place has never '
            'been cleaner. Will definitely book again!',
        providerResponse: 'Thank you! Happy to have you as a repeat client.',
        reviewsClient: maria,
        createdAt: DateTime(2024, 4, 12),
      ))
      ..add(ReviewDto(
        id: 'rev-2',
        rating: 4,
        comment:
            'Very thorough cleaning. Only thing was a slight delay in arrival, '
            'but the result was worth it.',
        providerResponse: '',
        reviewsClient: alex,
        createdAt: DateTime(2024, 3, 8),
      ));

    // Wire up which gig/provider each review belongs to.
    _reviewGigIds['rev-1'] = 'gig-2';
    _reviewGigIds['rev-2'] = 'gig-2';
    _reviewProviderIds['rev-1'] = 'prov-2';
    _reviewProviderIds['rev-2'] = 'prov-2';
  }
}
