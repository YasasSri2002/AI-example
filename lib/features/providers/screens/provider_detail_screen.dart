import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/provider_dto.dart';
import '../../../data/models/review_dto.dart';
import '../../../data/models/service_gig_dto.dart';
import '../../../data/repositories/gig_repository.dart';
import '../../../data/repositories/provider_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../features/reviews/widgets/review_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../service_gigs/widgets/service_gig_card.dart';

/// Full detail screen for a single service provider.
///
/// Displays provider profile information, their service gigs,
/// and a reviews placeholder (populated in Shot 8).
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({
    super.key,
    required this.providerId,
  });

  final String providerId;

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final ProviderRepository _providerRepository = ProviderRepository();
  final GigRepository _gigRepository = GigRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();

  ProviderWithCategory? _provider;
  List<ServiceGigResponseDto> _providerGigs = [];
  List<ReviewDto> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProviderDetails();
  }

  Future<void> _loadProviderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider =
          await _providerRepository.getProviderById(widget.providerId);

      // Also fetch gigs by this provider (using active gigs with filter if the API supports it)
      List<ServiceGigResponseDto> gigs = [];
      try {
        final allGigs = await _gigRepository.getActiveGigs(size: 100);
        gigs = allGigs
            .where((g) => g.provider?.id == widget.providerId)
            .toList();
      } catch (_) {
        // Non-critical — silently continue without gigs
      }

      if (mounted) {
        setState(() {
          _provider = provider;
          _providerGigs = gigs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load provider details.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const LoadingWidget(message: 'Loading provider details...')
          : _errorMessage != null
              ? _buildErrorState()
              : _provider != null
                  ? _buildContent()
                  : _buildNotFound(),
    );
  }

  Widget _buildContent() {
    final providerData = _provider!;
    final dto = providerData.providerDto;

    return CustomScrollView(
      slivers: [
        // ── Profile Header ──
        SliverAppBar(
          expandedHeight: 260,
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
                gradient: AppColors.profileGradient,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.surfaceSnow,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.accent400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name + Verified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            dto.fullName,
                            style: AppTextStyles.headingLg.copyWith(
                              color: AppColors.neutral800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (dto.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.success, size: 22),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Expertise
                    Text(
                      dto.expertise ?? 'Professional',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content Body ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats Row ──
                _buildStatsRow(providerData, dto),

                const SizedBox(height: 24),

                // ── Categories ──
                if (providerData.categoriesSet.isNotEmpty) ...[
                  Text('Specializations', style: AppTextStyles.headingSm),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: providerData.categoriesSet.map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.name,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accent600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── About ──
                if (dto.shortDescription != null &&
                    dto.shortDescription!.isNotEmpty) ...[
                  Text('About', style: AppTextStyles.headingSm),
                  const SizedBox(height: 8),
                  Text(dto.shortDescription!, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 24),
                ],

                // ── Contact Info ──
                _buildContactInfo(dto),

                const SizedBox(height: 24),

                // ── Service Gigs ──
                Text('Service Gigs', style: AppTextStyles.headingSm),
                const SizedBox(height: 12),
                if (_providerGigs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceIce100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.work_off_rounded,
                            size: 36, color: AppColors.neutral400),
                        const SizedBox(height: 8),
                        Text(
                          'No services listed yet',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._providerGigs
                      .map((gig) => ServiceGigCard(gig: gig)),

                const SizedBox(height: 24),

                // ── Reviews Placeholder (Shot 8) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceIce100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceIce200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          size: 40, color: AppColors.neutral400),
                      const SizedBox(height: 8),
                      Text(
                        'Reviews coming soon',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ProviderWithCategory data, ProviderDto dto) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            icon: Icons.star_rounded,
            iconColor: AppColors.rating,
            value: data.avgRate.toStringAsFixed(1),
            label: 'Rating',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral200,
          ),
          _buildStat(
            icon: Icons.rate_review_rounded,
            iconColor: AppColors.accent400,
            value: '${data.reviews}',
            label: 'Reviews',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutral200,
          ),
          _buildStat(
            icon: Icons.work_rounded,
            iconColor: AppColors.success,
            value: '${dto.jobCount}',
            label: 'Jobs',
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingSm.copyWith(
            color: AppColors.neutral800,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildContactInfo(ProviderDto dto) {
    final hasContact = dto.contactNo != null && dto.contactNo!.isNotEmpty;
    final hasEmail = dto.email != null && dto.email!.isNotEmpty;
    final hasAddress = dto.address != null && dto.address!.isNotEmpty;
    final hasExperience = dto.experience != null && dto.experience!.isNotEmpty;

    if (!hasContact && !hasEmail && !hasAddress && !hasExperience) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact & Details', style: AppTextStyles.headingSm),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSnow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceIce200),
          ),
          child: Column(
            children: [
              if (hasContact)
                _buildInfoRow(Icons.phone_rounded, dto.contactNo!),
              if (hasEmail)
                _buildInfoRow(Icons.email_rounded, dto.email!),
              if (hasAddress)
                _buildInfoRow(Icons.location_on_rounded, dto.address!),
              if (hasExperience)
                _buildInfoRow(
                    Icons.timeline_rounded, '${dto.experience} experience'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.neutral800,
              ),
            ),
          ),
        ],
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
              onPressed: _loadProviderDetails,
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
            const Icon(Icons.person_off_rounded,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              'Provider not found',
              style: AppTextStyles.headingMd
                  .copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 8),
            Text(
              'This provider may no longer be available.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/providers'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Providers'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.accent600),
            ),
          ],
        ),
      ),
    );
  }
}
