import 'package:json_annotation/json_annotation.dart';

part 'category_dto.g.dart';

/// Service category data transfer object.
///
/// Maps to the backend's CategoryResponseDto.
@JsonSerializable()
class CategoryResponseDto {
  const CategoryResponseDto({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseDtoToJson(this);

  @override
  String toString() => 'CategoryResponseDto(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryResponseDto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
