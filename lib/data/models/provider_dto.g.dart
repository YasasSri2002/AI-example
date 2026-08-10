// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderDto _$ProviderDtoFromJson(Map<String, dynamic> json) => ProviderDto(
  id: json['id'] as String,
  userName: json['userName'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  contactNo: json['contactNo'] as String?,
  expertise: json['expertise'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  address: json['address'] as String?,
  experience: json['experience'] as String?,
  jobCount: (json['jobCount'] as num?)?.toInt() ?? 0,
  shortDescription: json['shortDescription'] as String?,
);

Map<String, dynamic> _$ProviderDtoToJson(ProviderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'contactNo': instance.contactNo,
      'expertise': instance.expertise,
      'isVerified': instance.isVerified,
      'address': instance.address,
      'experience': instance.experience,
      'jobCount': instance.jobCount,
      'shortDescription': instance.shortDescription,
    };

ProviderWithCategory _$ProviderWithCategoryFromJson(
  Map<String, dynamic> json,
) => ProviderWithCategory(
  providerDto: ProviderDto.fromJson(
    json['providerDto'] as Map<String, dynamic>,
  ),
  categoriesSet:
      (json['categoriesSet'] as List<dynamic>?)
          ?.map((e) => CategoryResponseDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reviews: (json['reviews'] as num?)?.toInt() ?? 0,
  avgRate: (json['avgRate'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$ProviderWithCategoryToJson(
  ProviderWithCategory instance,
) => <String, dynamic>{
  'providerDto': instance.providerDto,
  'categoriesSet': instance.categoriesSet,
  'reviews': instance.reviews,
  'avgRate': instance.avgRate,
};
