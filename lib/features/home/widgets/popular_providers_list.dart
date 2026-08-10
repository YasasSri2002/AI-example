import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/provider_dto.dart';
import '../../../shared/widgets/loading_widget.dart';

/// A horizontal list of popular providers for the home screen.
class PopularProvidersList extends StatelessWidget {
  const PopularProvidersList({
    super.key,
    required this.providers,
    required this.isLoading,
  });

  final List<ProviderWithCategory> providers;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Providers',
                style: AppTextStyles.headingMd,
              ),
              TextButton(
                onPressed: () => context.push('/providers'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: isLoading
              ? _buildLoading()
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(right: 16),
          child: ShimmerCard(width: 140, height: 180),
        );
      },
    );
  }

  Widget _buildList() {
    if (providers.isEmpty) {
      return Center(
        child: Text(
          'No providers found.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final providerWithCategory = providers[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _ProviderMiniCard(provider: providerWithCategory),
        );
      },
    );
  }
}

class _ProviderMiniCard extends StatelessWidget {
  const _ProviderMiniCard({required this.provider});

  final ProviderWithCategory provider;

  @override
  Widget build(BuildContext context) {
    final dto = provider.providerDto;

    return GestureDetector(
      onTap: () => context.push('/providers/details/${dto.id}'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surfaceIce100,
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color: AppColors.accent400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dto.fullName,
              style: AppTextStyles.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              dto.expertise ?? 'Professional',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.neutral600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.rating, size: 14),
                const SizedBox(width: 2),
                Text(
                  provider.avgRate.toStringAsFixed(1),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                if (dto.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
