import 'package:json_annotation/json_annotation.dart';

import 'provider_dto.dart';
import 'service_gig_dto.dart';

part 'booking_dto.g.dart';

/// Booking request DTO — sent when creating a new booking.
@JsonSerializable()
class BookingRequestDto {
  const BookingRequestDto({
    required this.name,
    required this.email,
    required this.contactNo,
    required this.address,
    this.additionalInformation,
    this.status = 'pending',
    required this.startingTime,
    required this.startingDate,
    required this.providerId,
    required this.gigId,
  });

  final String name;
  final String email;
  final String contactNo;
  final String address;
  final String? additionalInformation;
  final String status;
  final String startingTime;
  final String startingDate;
  final String providerId;
  final String gigId;

  factory BookingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingRequestDtoToJson(this);

  @override
  String toString() => 'BookingRequestDto(name: $name, gigId: $gigId)';
}

/// Booking response DTO — received from the API with embedded relations.
@JsonSerializable()
class BookingResponseDto {
  const BookingResponseDto({
    required this.id,
    required this.name,
    this.email,
    this.contactNo,
    this.address,
    this.additionalInformation,
    required this.status,
    this.startingTime,
    this.startingDate,
    this.providerDto,
    this.serviceGigResponseDto,
  });

  final String id;
  final String name;
  final String? email;
  final String? contactNo;
  final String? address;
  final String? additionalInformation;
  final String status; // "pending" | "completed" | "cancelled"
  final String? startingTime;
  final String? startingDate;
  final ProviderDto? providerDto;
  final ServiceGigResponseDto? serviceGigResponseDto;

  /// Whether the booking can be cancelled.
  bool get canCancel => status.toLowerCase() == 'pending';

  /// Whether the booking can be rescheduled.
  bool get canReschedule => status.toLowerCase() == 'pending';

  /// Whether the booking can be marked as complete.
  bool get canComplete => status.toLowerCase() == 'pending';

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingResponseDtoToJson(this);

  @override
  String toString() => 'BookingResponseDto(id: $id, status: $status)';
}
