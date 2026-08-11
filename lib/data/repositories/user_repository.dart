import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../datasources/local/dummy_data.dart';
import '../models/user_dto.dart';

/// Repository for handling user operations.
///
/// Communicates with the Spring Boot REST API for user data retrieval
/// and profile management.
class UserRepository {
  /// Fetches a user by their [id].
  ///
  /// Corresponds to: GET `/users/by-id?id={id}`
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the dummy user
  /// matching [id] (or `null` if none exists).
  Future<UserResponseDto?> getUserById(String id) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.userById(id);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.usersById,
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch user by id ($id): $e');
      }
      rethrow;
    }
  }

  /// Fetches the currently authenticated user's data.
  ///
  /// Corresponds to: GET `/users/data`
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the dummy current
  /// user.
  Future<UserResponseDto?> getCurrentUser() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.currentUser;
    }

    try {
      final response = await DioClient.instance.get(ApiConstants.usersData);

      if (response.statusCode == 200 && response.data != null) {
        return UserResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch current user: $e');
      }
      rethrow;
    }
  }

  /// Updates the current user's profile data.
  ///
  /// Corresponds to: PUT `/users/update-user-data`
  ///
  /// When [ApiConstants.useMockApi] is enabled, persists the update in memory
  /// and returns the saved user.
  Future<UserResponseDto?> updateUser(UserResponseDto user) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.updateUser(user);
    }

    try {
      final response = await DioClient.instance.put(
        ApiConstants.usersUpdate,
        data: user.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user data: $e');
      }
      rethrow;
    }
  }

  /// Fetches the total booking count for a user identified by [userId].
  ///
  /// Corresponds to: GET `/users/booking-count-with-id?id={userId}`
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns the count of dummy
  /// bookings for the current user.
  Future<int> getBookingCount(String userId) async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.bookingCount(userId);
    }

    try {
      final response = await DioClient.instance.get(
        ApiConstants.usersBookingCount,
        queryParameters: {'id': userId},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is num) {
          return (response.data as num).toInt();
        }
        if (response.data is Map<String, dynamic>) {
          return ((response.data as Map<String, dynamic>)['count'] as num?)
                  ?.toInt() ??
              0;
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch booking count for user ($userId): $e');
      }
      return 0;
    }
  }
}
