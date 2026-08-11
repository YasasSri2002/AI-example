import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../datasources/local/dummy_data.dart';
import '../models/service_gig_dto.dart';

/// Repository for handling service gig operations.
///
/// Communicates with the Spring Boot REST API for all gig-related CRUD.
class GigRepository {
  /// Fetches a paginated list of active service gigs.
  ///
  /// [page] and [size] control pagination.
  /// [query] filters by search text. [categoryId] filters by category.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns a filtered and paged
  /// slice of the in-memory dummy gigs.
  Future<List<ServiceGigResponseDto>> getActiveGigs({
    int page = 0,
    int size = 10,
    String? query,
    String? categoryId,
  }) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.activeGigs(
        page: page,
        size: size,
        query: query,
        categoryId: categoryId,
      );
    }

    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (query != null && query.isNotEmpty) 'query': query,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      };

      final response = await DioClient.instance.get(
        ApiConstants.gigActiveGigs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        // API may return a paginated wrapper or a plain list
        final dynamic data = response.data;

        if (data is List) {
          return data
              .map((json) => ServiceGigResponseDto.fromJson(
                  json as Map<String, dynamic>))
              .toList();
        }

        // Handle Spring Boot Page<T> wrapper: { content: [...], totalPages, ... }
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final List<dynamic> content = data['content'] as List<dynamic>;
          return content
              .map((json) => ServiceGigResponseDto.fromJson(
                  json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch active gigs: $e');
      }
      rethrow;
    }
  }

  /// Fetches total page count for active gigs (for pagination).
  ///
  /// When [ApiConstants.useMockApi] is enabled, computes the page count from
  /// the dummy gig set using the same filtering rules.
  Future<int> getActiveGigsTotalPages({
    int size = 10,
    String? query,
    String? categoryId,
  }) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.activeGigsTotalPages(
        size: size,
        query: query,
        categoryId: categoryId,
      );
    }

    try {
      final queryParams = <String, dynamic>{
        'page': 0,
        'size': size,
        if (query != null && query.isNotEmpty) 'query': query,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      };

      final response = await DioClient.instance.get(
        ApiConstants.gigActiveGigs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('totalPages')) {
          return (data['totalPages'] as num?)?.toInt() ?? 1;
        }
      }
      return 1;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch total pages: $e');
      }
      return 1;
    }
  }

  /// Fetches all gigs (admin use).
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns all dummy gigs.
  Future<List<ServiceGigResponseDto>> getAllGigs() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.allGigs;
    }

    try {
      final response = await DioClient.instance.get(ApiConstants.gigAllGigs);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data as List<dynamic>
            : (response.data as Map<String, dynamic>)['content']
                    as List<dynamic>? ??
                [];
        return data
            .map((json) =>
                ServiceGigResponseDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch all gigs: $e');
      }
      return [];
    }
  }

  /// Fetches a single service gig by its [id].
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the dummy gig
  /// matching [id] (or `null` if none exists).
  Future<ServiceGigResponseDto?> getGigById(String id) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.gigById(id);
    }

    try {
      final response =
          await DioClient.instance.get('${ApiConstants.gigById}/$id');

      if (response.statusCode == 200 && response.data != null) {
        return ServiceGigResponseDto.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch gig by id ($id): $e');
      }
      rethrow;
    }
  }

  /// Fetches the average rating for a gig by [gigId].
  ///
  /// When [ApiConstants.useMockApi] is enabled, derives the rating from the
  /// dummy reviews for the gig's provider.
  Future<double> getAverageRating(String gigId) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.averageRating(gigId);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.gigAverageRating,
        queryParameters: {'id': gigId},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is num) {
          return (response.data as num).toDouble();
        }
        if (response.data is Map<String, dynamic>) {
          return ((response.data as Map<String, dynamic>)['averageRating']
                      as num?)
                  ?.toDouble() ??
              0.0;
        }
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch average rating for gig ($gigId): $e');
      }
      return 0.0;
    }
  }

  /// Fetches the count of all active gigs.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the count of active
  /// dummy gigs.
  Future<int> getActiveGigCount() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.activeGigCount;
    }

    try {
      final response =
          await DioClient.instance.get(ApiConstants.gigActiveCount);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is num) {
          return (response.data as num).toInt();
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch active gig count: $e');
      }
      return 0;
    }
  }

  /// Creates a new service gig.
  ///
  /// When [ApiConstants.useMockApi] is enabled, appends the gig to the
  /// in-memory store and returns the created response DTO.
  Future<ServiceGigResponseDto?> createGig(ServiceGigDto gig) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.createGig(gig);
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.gigCreate,
        data: gig.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceGigResponseDto.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create gig: $e');
      }
      rethrow;
    }
  }
}
