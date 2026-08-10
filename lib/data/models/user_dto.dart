import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

/// User response data transfer object.
@JsonSerializable()
class UserResponseDto {
  const UserResponseDto({
    required this.id,
    this.address,
    this.contact,
    this.email,
    this.paymentMethod,
    this.firstName,
    this.lastName,
    this.username,
    this.createdAt,
  });

  final String id;
  final String? address;
  final String? contact;
  final String? email;
  final String? paymentMethod;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? createdAt;

  /// Full display name.
  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim().isNotEmpty
          ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
          : username ?? 'Unknown';

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDtoToJson(this);

  @override
  String toString() => 'UserResponseDto(id: $id, name: $fullName)';
}

/// Minimal user DTO used in nested objects (e.g., reviews).
@JsonSerializable()
class UserDto {
  const UserDto({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;

  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim().isNotEmpty
          ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
          : username ?? 'Anonymous';

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
