import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/review_dto.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'review_card.dart';
import 'review_form.dart';

/// Section displaying reviews for a service gig.
///
/// Shows the average rating, a list of [ReviewCard] widgets,
/// and a [ReviewForm] for submitting new reviews.
/// Handles loading, error, and empty states.
class ReviewSection extends StatefulWidget {
  const ReviewSection({
    super.key,
    required this.gigId,
    required this.providerId,
    this.initialAverageRating = 0.0,
  });

  final String gigId;
  final String providerId;
  final double initialAverageRating;

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final ReviewRepository _reviewRepository = ReviewRepository();

  List<ReviewDto> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews =
          await _reviewRepository.getReviewsByGigId(widget.gigId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load reviews. Please try again.';
        });
      }
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return widget.initialAverageRating;
    final total = _reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Title + Average Rating ──
        _buildHeader(),

        const SizedBox(height: 16),

        // ── Content ──
        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_reviews.isEmpty)
          _buildEmptyState()
        else
          _buildReviewList(),

        const SizedBox(height: 24),

        // ── Review Form ──
        ReviewForm(
          gigId: widget.gigId,
          providerId: widget.providerId,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reviews',
          style: AppTextStyles.headingSm.copyWith(
            color: AppColors.neutral800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceIce100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceIce200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: AppColors.rating,
              ),
              const SizedBox(width: 4),
              Text(
                _averageRating.toStringAsFixed(1),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '(${_reviews.length})',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ShimmerCard(height: 100),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadReviews,
              child: Text(
                'Retry',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.accent600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 12),
            Text(
              'No reviews yet',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share your experience.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return ReviewCard(key: ValueKey(review.id ?? index), review: review);
      },
    );
  }
}
