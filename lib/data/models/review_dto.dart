import 'package:json_annotation/json_annotation.dart';

import 'user_dto.dart';

part 'review_dto.g.dart';

/// Review data transfer object — received from the API.
@JsonSerializable()
class ReviewDto {
  const ReviewDto({
    this.id,
    required this.rating,
    this.comment,
    this.providerResponse,
    this.reviewsClient,
    this.createdAt,
  });

  final String? id;
  final int rating;
  final String? comment;
  final String? providerResponse;
  final UserDto? reviewsClient;
  final DateTime? createdAt;

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  @override
  String toString() => 'ReviewDto(id: $id, rating: $rating)';
}

/// Review request DTO — sent when submitting a new review.
@JsonSerializable()
class ReviewRequestDto {
  const ReviewRequestDto({
    required this.rating,
    required this.comment,
    this.serviceGigId,
    required this.providerId,
    this.clientId,
  });

  final int rating;
  final String comment;
  final String? serviceGigId;
  final String providerId;
  final String? clientId;

  factory ReviewRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRequestDtoToJson(this);

  @override
  String toString() =>
      'ReviewRequestDto(rating: $rating, providerId: $providerId)';
}
