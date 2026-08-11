import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../datasources/local/dummy_data.dart';
import '../models/review_dto.dart';

/// Repository for handling service review operations.
///
/// Communicates with the Spring Boot REST API for fetching
/// and submitting reviews for service gigs.
class ReviewRepository {
  /// Fetches all reviews for a service gig identified by [gigId].
  ///
  /// Corresponds to: GET `/review/by-gig-id?id={gigId}`
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the dummy reviews
  /// associated with the gig.
  Future<List<ReviewDto>> getReviewsByGigId(String gigId) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.reviewsByGigId(gigId);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.reviewByGigId,
        queryParameters: {'id': gigId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;

        // Handle plain list response
        if (data is List) {
          return data
              .map((json) => ReviewDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        // Handle Spring Boot Page<T> wrapper
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final content = data['content'] as List<dynamic>;
          return content
              .map(
                (json) =>
                    ReviewDto.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch reviews for gig ($gigId): $e');
      }
      rethrow;
    }
  }

  /// Submits a new review via the API.
  ///
  /// Corresponds to: POST `/review/add-review`
  /// Returns the created [ReviewDto] if successful, `null` otherwise.
  ///
  /// When [ApiConstants.useMockApi] is enabled, appends the review to the
  /// in-memory store and returns the created DTO.
  Future<ReviewDto?> addReview(ReviewRequestDto review) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.addReview(review);
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.reviewAdd,
        data: review.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return ReviewDto.fromJson(
            response.data as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add review: $e');
      }
      rethrow;
    }
  }
}
