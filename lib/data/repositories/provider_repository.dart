import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../datasources/local/dummy_data.dart';
import '../models/provider_dto.dart';

/// Repository for handling service provider operations.
///
/// Communicates with the Spring Boot REST API for all provider-related queries.
class ProviderRepository {
  /// Fetches a paginated list of all providers with their categories.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns a paged slice of the
  /// in-memory dummy providers.
  Future<List<ProviderWithCategory>> getAllProviders({
    int page = 0,
    int size = 10,
  }) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.providersPage(page: page, size: size);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.providerAll,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;

        if (data is List) {
          return data
              .map((json) => ProviderWithCategory.fromJson(
                  json as Map<String, dynamic>))
              .toList();
        }

        // Handle Spring Boot Page<T> wrapper
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final List<dynamic> content = data['content'] as List<dynamic>;
          return content
              .map((json) => ProviderWithCategory.fromJson(
                  json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch all providers: $e');
      }
      rethrow;
    }
  }

  /// Fetches total page count for providers (for pagination).
  ///
  /// When [ApiConstants.useMockApi] is enabled, derives the page count from
  /// the dummy provider set.
  Future<int> getProvidersTotalPages({int size = 10}) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.providersTotalPages(size: size);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.providerAll,
        queryParameters: {'page': 0, 'size': size},
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
        debugPrint('Failed to fetch provider total pages: $e');
      }
      return 1;
    }
  }

  /// Fetches a single provider by [id] with categories, reviews, and rating.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the dummy provider
  /// matching [id] (or `null` if none exists).
  Future<ProviderWithCategory?> getProviderById(String id) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.providerById(id);
    }

    try {
      final response =
          await DioClient.instance.get('${ApiConstants.providerById}/$id');

      if (response.statusCode == 200 && response.data != null) {
        return ProviderWithCategory.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch provider by id ($id): $e');
      }
      rethrow;
    }
  }

  /// Fetches a list of popular/featured providers.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the top-rated dummy
  /// providers.
  Future<List<ProviderWithCategory>> getPopularProviders() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.popularProviders;
    }

    try {
      final response =
          await DioClient.instance.get(ApiConstants.providerPopular);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data as List<dynamic>
            : [];
        return data
            .map((json) =>
                ProviderWithCategory.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch popular providers: $e');
      }
      return [];
    }
  }

  /// Fetches the total count of registered providers.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the count of dummy
  /// providers.
  Future<int> getProviderCount() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.providerCount;
    }

    try {
      final response =
          await DioClient.instance.get(ApiConstants.providerCount);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is num) {
          return (response.data as num).toInt();
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch provider count: $e');
      }
      return 0;
    }
  }

  /// Registers a new provider.
  ///
  /// When [ApiConstants.useMockApi] is enabled, creates and returns a dummy
  /// [ProviderDto] built from [data].
  Future<ProviderDto?> registerProvider(Map<String, dynamic> data) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.registerProvider(data);
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.providerPersist,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProviderDto.fromJson(
            response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to register provider: $e');
      }
      rethrow;
    }
  }
}
