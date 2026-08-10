import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/review_dto.dart';
import '../../../data/repositories/review_repository.dart';

/// A form widget for submitting a new service review.
///
/// Displays a tappable 1–5 star selector, a comment text area,
/// and a submit button. On success, invokes [onReviewSubmitted].
class ReviewForm extends StatefulWidget {
  const ReviewForm({
    super.key,
    required this.gigId,
    required this.providerId,
  });

  final String gigId;
  final String providerId;

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final ReviewRepository _reviewRepository = ReviewRepository();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      setState(() => _errorMessage = 'Please select a rating');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final reviewRequest = ReviewRequestDto(
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        providerId: widget.providerId,
        serviceGigId: widget.gigId,
      );

      final result = await _reviewRepository.addReview(reviewRequest);

      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review submitted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _commentController.clear();
        setState(() => _selectedRating = 0);
        _formKey.currentState?.reset();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to submit review. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: AppTextStyles.headingSm.copyWith(
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 12),

            // ── Star Rating Selector ──
            _buildStarSelector(),
            if (_errorMessage != null && _errorMessage!.contains('rating'))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // ── Comment Text Area ──
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'What was your experience?',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.neutral400,
                ),
                filled: true,
                fillColor: AppColors.surfaceIce100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent600, width: 2),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
              validator: Validators.required,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _submitReview(),
            ),

            if (_errorMessage != null &&
                !_errorMessage!.contains('rating'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surfaceSnow,
                        ),
                      )
                    : Text(
                        'Submit Review',
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      children: [
        Text(
          'Your Rating:',
          style: AppTextStyles.label.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final isSelected = index < _selectedRating;
            return GestureDetector(
              onTap: _isSubmitting ? null : () {
                setState(() => _selectedRating = index + 1);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isSelected
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 28,
                  color: isSelected ? AppColors.rating : AppColors.neutral400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
