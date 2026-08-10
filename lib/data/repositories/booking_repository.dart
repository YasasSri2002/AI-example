import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_dto.dart';

/// Repository for handling booking operations.
///
/// Communicates with the Spring Boot REST API for all booking CRUD.
class BookingRepository {
  /// Creates a new booking via the API.
  ///
  /// Returns the created [BookingResponseDto] if successful, `null` otherwise.
  Future<BookingResponseDto?> createBooking(
    BookingRequestDto booking,
  ) async {
    try {
      final response = await DioClient.instance.post(
        ApiConstants.bookingPersist,
        data: booking.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return BookingResponseDto.fromJson(
            response.data as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create booking: $e');
      }
      rethrow;
    }
  }

  /// Fetches all bookings for the currently authenticated client.
  Future<List<BookingResponseDto>> getBookingsByClient() async {
    try {
      final response = await DioClient.instance.get(
        ApiConstants.bookingByClientId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;

        if (data is List) {
          return data
              .map((json) =>
                  BookingResponseDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        // Handle Spring Boot Page<T> wrapper
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final content = data['content'] as List<dynamic>;
          return content
              .map((json) =>
                  BookingResponseDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch bookings by client: $e');
      }
      rethrow;
    }
  }

  /// Cancels a booking by [bookingId].
  ///
  /// Sends a PUT request to the cancel endpoint.
  /// Returns `true` if the cancellation was successful.
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final response = await DioClient.instance.put(
        ApiConstants.bookingCancel,
        data: {'bookingId': bookingId},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to cancel booking ($bookingId): $e');
      }
      rethrow;
    }
  }

  /// Reschedules a booking with a new [date] and [time].
  ///
  /// Returns `true` if the reschedule was successful.
  Future<bool> rescheduleBooking(
    String bookingId,
    String date,
    String time,
  ) async {
    try {
      final response = await DioClient.instance.put(
        ApiConstants.bookingReschedule,
        data: {
          'bookingId': bookingId,
          'startingDate': date,
          'startingTime': time,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to reschedule booking ($bookingId): $e');
      }
      rethrow;
    }
  }

  /// Marks a booking as completed by [bookingId].
  ///
  /// Returns `true` if the operation was successful.
  Future<bool> markComplete(String bookingId) async {
    try {
      final response = await DioClient.instance.put(
        ApiConstants.bookingMarkComplete,
        data: {'bookingId': bookingId},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark booking complete ($bookingId): $e');
      }
      rethrow;
    }
  }
}
