import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pagination controls widget with Previous, Next, and Page Indicator.
class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            icon: Icons.chevron_left_rounded,
            label: 'Previous',
            onTap: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: AppTextStyles.label,
          ),
          const SizedBox(width: 16),
          _buildButton(
            icon: Icons.chevron_right_rounded,
            label: 'Next',
            isNext: true,
            onTap: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isNext = false,
  }) {
    final bool isEnabled = onTap != null;
    final color = isEnabled ? AppColors.accent600 : AppColors.neutral400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (!isNext) Icon(icon, color: color, size: 20),
            if (!isNext) const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: color),
            ),
            if (isNext) const SizedBox(width: 4),
            if (isNext) Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
