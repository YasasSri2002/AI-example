import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/service_gig_dto.dart';

/// A card widget for displaying a service gig in list views.
///
/// Shows title, description, formatted price, category badge,
/// provider info, and booking count. Taps navigate to gig detail.
class ServiceGigCard extends StatelessWidget {
  const ServiceGigCard({
    super.key,
    required this.gig,
  });

  final ServiceGigResponseDto gig;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service-gigs/details/${gig.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title & Category Row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      gig.title,
                      style: AppTextStyles.headingSm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (gig.category != null) ...[
                    const SizedBox(width: 8),
                    _CategoryBadge(name: gig.category!.name),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // ── Description ──
              if (gig.description != null && gig.description!.isNotEmpty)
                Text(
                  gig.description!,
                  style: AppTextStyles.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // ── Price ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gig.formattedPrice,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accent600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Provider Info & Booking Count ──
              Row(
                children: [
                  // Provider avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.surfaceIce100,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppColors.accent400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            gig.provider?.fullName ?? 'Unknown Provider',
                            style: AppTextStyles.bodySm.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (gig.provider?.isVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Booking count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gig.totalBookingCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
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

/// Small category badge chip.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceIce100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceIce200),
      ),
      child: Text(
        name,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
