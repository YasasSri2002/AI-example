import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/category_dto.dart';

/// Repository for handling service category operations.
class CategoryRepository {
  /// Fetches all service categories from the API.
  Future<List<CategoryResponseDto>> getAllCategories() async {
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
  Future<CategoryResponseDto?> addCategory(CategoryResponseDto category) async {
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
