import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/provider_dto.dart';

/// A card widget for displaying a provider in grid/list views.
///
/// Shows avatar, name, verification badge, expertise, category chips,
/// star rating, and review count. Taps navigate to provider detail.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
  });

  final ProviderWithCategory provider;

  @override
  Widget build(BuildContext context) {
    final providerDto = provider.providerDto;

    return GestureDetector(
      onTap: () => context.push('/providers/details/${providerDto.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSnow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceIce200),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Avatar ──
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceIce100,
                child: const Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: AppColors.accent400,
                ),
              ),

              const SizedBox(height: 12),

              // ── Name + Verification ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      providerDto.fullName,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral800,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (providerDto.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              // ── Expertise ──
              Text(
                providerDto.expertise ?? 'Professional',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // ── Category Chips ──
              if (provider.categoriesSet.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: provider.categoriesSet
                      .take(2) // Show max 2 categories on card
                      .map((cat) => _CategoryChip(name: cat.name))
                      .toList(),
                ),

              const SizedBox(height: 8),

              // ── Rating & Reviews ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.rating,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    provider.avgRate.toStringAsFixed(1),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.neutral800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${provider.reviews} ${provider.reviews == 1 ? 'review' : 'reviews'})',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small category chip for provider cards.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accent600,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
