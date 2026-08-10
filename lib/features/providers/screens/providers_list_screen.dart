import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/provider_dto.dart';
import '../../../data/repositories/provider_repository.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/pagination_controls.dart';
import '../widgets/provider_card.dart';

/// Grid display of all registered service providers.
///
/// Paginated 2-column grid with pull-to-refresh and
/// loading/error/empty states.
class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({super.key});

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  final ProviderRepository _providerRepository = ProviderRepository();

  List<ProviderWithCategory> _providers = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = true;
  String? _errorMessage;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _providerRepository.getAllProviders(
          page: _currentPage,
          size: _pageSize,
        ),
        _providerRepository.getProvidersTotalPages(size: _pageSize),
      ]);

      if (mounted) {
        setState(() {
          _providers = results[0] as List<ProviderWithCategory>;
          _totalPages = results[1] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load providers. Please try again.';
        });
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceSnow,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Providers', style: AppTextStyles.headingMd),
        centerTitle: false,
        surfaceTintColor: AppColors.surfaceSnow,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProviders,
        color: AppColors.accent600,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerGrid();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_providers.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Provider count header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  '${_providers.length} providers',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),

          // 2-column grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: _providers.length,
            itemBuilder: (context, index) {
              return ProviderCard(provider: _providers[index]);
            },
          ),

          PaginationControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: _onPageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const ShimmerCard(height: 200);
        },
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
              onPressed: _loadProviders,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              'No providers found',
              style: AppTextStyles.headingMd
                  .copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new service providers.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
