import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/service_gig_dto.dart';
import '../../../data/repositories/gig_repository.dart';
import '../../../features/reviews/widgets/review_section.dart';
import '../../../shared/widgets/loading_widget.dart';

/// Full detail screen for a single service gig.
///
/// Displays complete gig info with gradient background, provider card,
/// average rating, and a Book Now button (booking form added in Shot 7).
class GigDetailScreen extends StatefulWidget {
  const GigDetailScreen({
    super.key,
    required this.gigId,
  });

  final String gigId;

  @override
  State<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends State<GigDetailScreen> {
  final GigRepository _gigRepository = GigRepository();

  ServiceGigResponseDto? _gig;
  double _averageRating = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGigDetails();
  }

  Future<void> _loadGigDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _gigRepository.getGigById(widget.gigId),
        _gigRepository.getAverageRating(widget.gigId),
      ]);

      if (mounted) {
        setState(() {
          _gig = results[0] as ServiceGigResponseDto?;
          _averageRating = results[1] as double;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load service details.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const LoadingWidget(message: 'Loading service details...')
          : _errorMessage != null
              ? _buildErrorState()
              : _gig != null
                  ? _buildContent()
                  : _buildNotFound(),
    );
  }

  Widget _buildContent() {
    final gig = _gig!;

    return CustomScrollView(
      slivers: [
        // ── Gradient App Bar ──
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: AppColors.surfaceSnow,
          surfaceTintColor: AppColors.surfaceSnow,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSnow.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.neutral800),
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.serviceDetailGradient,
              ),
              child: Center(
                child: Icon(
                  Icons.work_rounded,
                  size: 64,
                  color: AppColors.accent400.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),

        // ── Content ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                if (gig.category != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      gig.category!.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Title
                Text(gig.title, style: AppTextStyles.headingXl),

                const SizedBox(height: 8),

                // Rating row
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.rating, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(
                      '${gig.totalBookingCount} bookings',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Price Card ──
                _buildPriceCard(gig),

                const SizedBox(height: 24),

                // ── Description ──
                Text('Description', style: AppTextStyles.headingSm),
                const SizedBox(height: 8),
                Text(
                  gig.description ?? 'No description provided.',
                  style: AppTextStyles.bodyMd,
                ),

                // ── Service Location ──
                if (gig.serviceLocation != null &&
                    gig.serviceLocation!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 18, color: AppColors.accent600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          gig.serviceLocation!,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // ── Provider Card ──
                if (gig.provider != null) _buildProviderCard(gig),

                const SizedBox(height: 24),

                // ── Reviews Section ──
                ReviewSection(
                  gigId: gig.id,
                  providerId: gig.provider?.id ?? '',
                  initialAverageRating: _averageRating,
                ),

                // Bottom spacing for the floating button
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(ServiceGigResponseDto gig) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent600, AppColors.accent500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent600.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.surfaceSnow.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gig.formattedPrice,
                style: AppTextStyles.headingMd.copyWith(
                  color: AppColors.surfaceSnow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          FilledButton(
            onPressed: () {
              final provider = gig.provider;
              context.pushNamed(
                'booking-form',
                queryParameters: {
                  'gigId': gig.id,
                  if (provider != null) 'providerId': provider.id,
                  if (provider != null) 'providerName': provider.fullName,
                  'gigTitle': gig.title,
                },
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceSnow,
              foregroundColor: AppColors.accent600,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ServiceGigResponseDto gig) {
    final provider = gig.provider!;

    return GestureDetector(
      onTap: () => context.push('/providers/details/${provider.id}'),
      child: Container(
        width: double.infinity,
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceIce100,
              child: const Icon(
                Icons.person_rounded,
                size: 24,
                color: AppColors.accent400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.fullName,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    provider.expertise ?? 'Professional',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadGigDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.accent600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              'Service not found',
              style: AppTextStyles.headingMd
                  .copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 8),
            Text(
              'This service may have been removed or is no longer available.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/service-gigs'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Services'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.accent600),
            ),
          ],
        ),
      ),
    );
  }
}
