import 'package:json_annotation/json_annotation.dart';

import 'category_dto.dart';
import 'provider_dto.dart';

part 'service_gig_dto.g.dart';

/// Service gig data transfer object (for creation/update).
@JsonSerializable()
class ServiceGigDto {
  const ServiceGigDto({
    this.id,
    required this.title,
    this.shortDescription,
    this.fullDescription,
    required this.basePrice,
    required this.priceType,
    this.durationByHours,
    required this.currency,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String? shortDescription;
  final String? fullDescription;
  final double basePrice;
  final String priceType; // "Hourly" | "Per Job" | "Per Day"
  final double? durationByHours;
  final String currency; // "LKR" | "USD"
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ServiceGigDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceGigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceGigDtoToJson(this);

  @override
  String toString() => 'ServiceGigDto(id: $id, title: $title)';
}

/// Service gig response DTO with embedded provider and category relations.
@JsonSerializable()
class ServiceGigResponseDto {
  const ServiceGigResponseDto({
    required this.id,
    required this.title,
    this.serviceLocation,
    this.description,
    required this.basePrice,
    required this.priceType,
    this.totalBookingCount = 0,
    required this.currency,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.provider,
    this.category,
  });

  final String id;
  final String title;
  final String? serviceLocation;
  final String? description;
  final double basePrice;
  final String priceType;
  final int totalBookingCount;
  final String currency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProviderDto? provider;
  final CategoryResponseDto? category;

  /// Formatted price string (e.g., "LKR 2,500 / Hourly").
  String get formattedPrice {
    final priceStr = basePrice.toStringAsFixed(basePrice == basePrice.roundToDouble() ? 0 : 2);
    return '$currency $priceStr / $priceType';
  }

  factory ServiceGigResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceGigResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceGigResponseDtoToJson(this);

  @override
  String toString() => 'ServiceGigResponseDto(id: $id, title: $title)';
}
