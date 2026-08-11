import 'package:flutter_test/flutter_test.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:nestify/core/constants/api_constants.dart';
import 'package:nestify/data/datasources/local/dummy_data.dart';
import 'package:nestify/data/models/review_dto.dart';

void main() {
  group('DummyData – mock API mode', () {
    test('useMockApi toggle is enabled', () {
      expect(ApiConstants.useMockApi, isTrue);
    });

    test('dummy JWT decodes and is not expired with the user role', () {
      final token = DummyData.instance.generateJwt();
      expect(JwtDecoder.isExpired(token), isFalse);

      final decoded = JwtDecoder.decode(token);
      expect(decoded['sub'], DummyData.dummyUserId);
      expect(decoded['email'], DummyData.dummyUserEmail);
      expect(decoded['name'], DummyData.dummyUserName);

      final realmAccess = decoded['realm_access'] as Map<String, dynamic>;
      expect(
        (realmAccess['roles'] as List<dynamic>).contains('user'),
        isTrue,
      );
    });

    test('categories, providers, gigs, bookings, reviews are populated', () {
      final data = DummyData.instance;
      expect(data.categories, isNotEmpty);
      expect(data.providers, isNotEmpty);
      expect(data.gigs, isNotEmpty);
      expect(data.bookingsByClient, isNotEmpty);

      final gigReviews = data.reviewsByGigId('gig-2');
      expect(gigReviews, isNotEmpty);
    });

    test('lookup helpers resolve by id', () {
      final data = DummyData.instance;
      expect(data.providerById('prov-1'), isNotNull);
      expect(data.providerById('nope'), isNull);
      expect(data.gigById('gig-2'), isNotNull);
      expect(data.userById(DummyData.dummyUserId), isNotNull);
    });

    test('pagination slices providers correctly', () {
      final data = DummyData.instance;
      expect(data.providersPage(page: 0, size: 2).length, lessThanOrEqualTo(2));
      expect(data.providersTotalPages(size: 2), greaterThanOrEqualTo(1));
      expect(data.providerCount, greaterThan(0));
    });

    test('gig filtering respects search text', () {
      final data = DummyData.instance;
      final filtered = data.activeGigs(query: 'cleaning', size: 100);
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((g) => g.title.toLowerCase().contains('cleaning')),
        isTrue,
      );
    });

    test('cancel mutates booking state in memory', () {
      final data = DummyData.instance;
      expect(data.averageRating('gig-2'), greaterThan(0));

      final before = data.bookingsByClient;
      final pending = before.firstWhere((b) => b.canCancel);
      final id = pending.id;

      expect(data.cancelBooking(id), isTrue);
      final after = data.bookingsByClient;
      final cancelled = after.firstWhere((b) => b.id == id);
      expect(cancelled.status.toLowerCase(), 'cancelled');
      expect(cancelled.canCancel, isFalse);
    });

    test('addReview appends a review for the gig', () {
      final data = DummyData.instance;
      final before = data.reviewsByGigId('gig-2').length;
      final created = data.addReview(
        const ReviewRequestDto(
          rating: 5,
          comment: 'Great service!',
          providerId: 'prov-2',
          serviceGigId: 'gig-2',
        ),
      );
      expect(created, isNotNull);
      expect(data.reviewsByGigId('gig-2').length, greaterThan(before));
    });
  });
}
