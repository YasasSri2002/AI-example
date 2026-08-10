// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_gig_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceGigDto _$ServiceGigDtoFromJson(Map<String, dynamic> json) =>
    ServiceGigDto(
      id: json['id'] as String?,
      title: json['title'] as String,
      shortDescription: json['shortDescription'] as String?,
      fullDescription: json['fullDescription'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      priceType: json['priceType'] as String,
      durationByHours: (json['durationByHours'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceGigDtoToJson(ServiceGigDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'shortDescription': instance.shortDescription,
      'fullDescription': instance.fullDescription,
      'basePrice': instance.basePrice,
      'priceType': instance.priceType,
      'durationByHours': instance.durationByHours,
      'currency': instance.currency,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ServiceGigResponseDto _$ServiceGigResponseDtoFromJson(
  Map<String, dynamic> json,
) => ServiceGigResponseDto(
  id: json['id'] as String,
  title: json['title'] as String,
  serviceLocation: json['serviceLocation'] as String?,
  description: json['description'] as String?,
  basePrice: (json['basePrice'] as num).toDouble(),
  priceType: json['priceType'] as String,
  totalBookingCount: (json['totalBookingCount'] as num?)?.toInt() ?? 0,
  currency: json['currency'] as String,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  provider: json['provider'] == null
      ? null
      : ProviderDto.fromJson(json['provider'] as Map<String, dynamic>),
  category: json['category'] == null
      ? null
      : CategoryResponseDto.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ServiceGigResponseDtoToJson(
  ServiceGigResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'serviceLocation': instance.serviceLocation,
  'description': instance.description,
  'basePrice': instance.basePrice,
  'priceType': instance.priceType,
  'totalBookingCount': instance.totalBookingCount,
  'currency': instance.currency,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'provider': instance.provider,
  'category': instance.category,
};
