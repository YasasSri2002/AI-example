import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/category_dto.dart';
import 'search_bar.dart';

/// The hero section of the home screen.
class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.categories,
    required this.onSearch,
  });

  final List<CategoryResponseDto> categories;
  final void Function(String query, String? categoryId) onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Trusted\nProfessionals',
            style: AppTextStyles.displayLg.copyWith(
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Book expert services for your home instantly.',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 32),
          
          HomeSearchBar(
            categories: categories,
            onSearch: onSearch,
          ),
          
          const SizedBox(height: 24),
          
          // Popular Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Cleaning'),
              _buildTag('Plumbing'),
              _buildTag('Electrical'),
              _buildTag('Gardening'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSnow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceIce200),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.primary800),
      ),
    );
  }
}
