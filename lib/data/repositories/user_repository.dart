import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/user_dto.dart';

/// Repository for handling user operations.
///
/// Communicates with the Spring Boot REST API for user data retrieval
/// and profile management.
class UserRepository {
  /// Fetches a user by their [id].
  ///
  /// Corresponds to: GET `/users/by-id?id={id}`
  Future<UserResponseDto?> getUserById(String id) async {
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
  Future<UserResponseDto?> getCurrentUser() async {
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
  Future<UserResponseDto?> updateUser(UserResponseDto user) async {
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
  Future<int> getBookingCount(String userId) async {
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
