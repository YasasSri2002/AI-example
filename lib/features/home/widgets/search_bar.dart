import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/category_dto.dart';

/// A search bar with text input and a category dropdown.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.categories,
    required this.onSearch,
  });

  final List<CategoryResponseDto> categories;
  final void Function(String query, String? categoryId) onSearch;

  @override
  Widget build(BuildContext context) {
    // In a real implementation, these would be tracked in state
    String query = '';
    String? selectedCategoryId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSnow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search Input
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) => query = val,
              decoration: InputDecoration(
                hintText: 'What service do you need?',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: const Icon(Icons.search_rounded, color: AppColors.neutral400),
                hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
              ),
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 32,
            color: AppColors.neutral200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Category Dropdown
          Expanded(
            flex: 1,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Category'),
                value: selectedCategoryId,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral600),
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedCategoryId = val;
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Search Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.accent600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => onSearch(query, selectedCategoryId),
              icon: const Icon(Icons.search_rounded, color: AppColors.surfaceSnow),
            ),
          ),
        ],
      ),
    );
  }
}
