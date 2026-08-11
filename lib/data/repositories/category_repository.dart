import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../datasources/local/dummy_data.dart';
import '../models/category_dto.dart';

/// Repository for handling service category operations.
class CategoryRepository {
  /// Fetches all service categories.
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns in-memory dummy data.
  Future<List<CategoryResponseDto>> getAllCategories() async {
    if (ApiConstants.useMockApi) {
      return DummyData.instance.categories;
    }

    try {
      final response = await DioClient.instance.get(ApiConstants.categoryAll);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => CategoryResponseDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch categories: $e');
      }
      return [];
    }
  }

  /// Adds a new category (Admin only).
  ///
  /// When [ApiConstants.useMockApi] is enabled, returns a dummy category
  /// built from the provided data.
  Future<CategoryResponseDto?> addCategory(CategoryResponseDto category) async {
    if (ApiConstants.useMockApi) {
      return category;
    }

    try {
      final response = await DioClient.instance.post(
        ApiConstants.categoryAdd,
        data: category.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CategoryResponseDto.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add category: $e');
      }
      return null;
    }
  }
}
