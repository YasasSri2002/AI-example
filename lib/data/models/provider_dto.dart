import 'package:json_annotation/json_annotation.dart';

import 'category_dto.dart';

part 'provider_dto.g.dart';

/// Service provider data transfer object.
@JsonSerializable()
class ProviderDto {
  const ProviderDto({
    required this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.contactNo,
    this.expertise,
    this.isVerified = false,
    this.address,
    this.experience,
    this.jobCount = 0,
    this.shortDescription,
  });

  final String id;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? contactNo;
  final String? expertise;
  final bool isVerified;
  final String? address;
  final String? experience;
  final int jobCount;
  final String? shortDescription;

  /// Full display name.
  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim().isNotEmpty
          ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
          : userName ?? 'Unknown';

  factory ProviderDto.fromJson(Map<String, dynamic> json) =>
      _$ProviderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderDtoToJson(this);

  @override
  String toString() => 'ProviderDto(id: $id, name: $fullName)';
}

/// Provider with associated categories, review count, and average rating.
@JsonSerializable()
class ProviderWithCategory {
  const ProviderWithCategory({
    required this.providerDto,
    this.categoriesSet = const [],
    this.reviews = 0,
    this.avgRate = 0.0,
  });

  final ProviderDto providerDto;
  final List<CategoryResponseDto> categoriesSet;
  final int reviews;
  final double avgRate;

  factory ProviderWithCategory.fromJson(Map<String, dynamic> json) =>
      _$ProviderWithCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderWithCategoryToJson(this);

  @override
  String toString() =>
      'ProviderWithCategory(provider: ${providerDto.fullName}, '
      'categories: ${categoriesSet.length}, reviews: $reviews, '
      'avgRate: $avgRate)';
}
