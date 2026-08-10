import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/review_dto.dart';

/// A card widget for displaying a single service review.
///
/// Shows the star rating, review comment, client name, and creation date.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
  });

  final ReviewDto review;

  @override
  Widget build(BuildContext context) {
    final clientName = review.reviewsClient?.fullName ?? 'Anonymous';
    final dateStr = review.createdAt != null
        ? DateFormat('MMM d, y').format(review.createdAt!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSnow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceIce200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Client + Date ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clientName,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
              if (dateStr != null)
                Text(
                  dateStr,
                  style: AppTextStyles.caption,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Star Rating ──
          _buildStarRating(review.rating),
          const SizedBox(height: 8),

          // ── Comment ──
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(
              review.comment!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),

          // ── Provider Response ──
          if (review.providerResponse != null &&
              review.providerResponse!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceIce100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceIce200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider Response',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.providerResponse!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: 16,
          color: filled ? AppColors.rating : AppColors.neutral400,
        );
      }),
    );
  }
}
