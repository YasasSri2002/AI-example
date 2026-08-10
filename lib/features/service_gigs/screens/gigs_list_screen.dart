import 'dart:async';

import 'package:flutter/material.dart';


import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/service_gig_dto.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/gig_repository.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/pagination_controls.dart';
import '../widgets/service_gig_card.dart';

/// Paginated, searchable list of active service gigs.
///
/// Accepts optional `query` and `category` query parameters from the route
/// to pre-populate the search and filter.
class GigsListScreen extends StatefulWidget {
  const GigsListScreen({
    super.key,
    this.initialQuery,
    this.initialCategoryId,
  });

  final String? initialQuery;
  final String? initialCategoryId;

  @override
  State<GigsListScreen> createState() => _GigsListScreenState();
}

class _GigsListScreenState extends State<GigsListScreen> {
  final GigRepository _gigRepository = GigRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<ServiceGigResponseDto> _gigs = [];
  List<CategoryResponseDto> _categories = [];
  String? _selectedCategoryId;
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = true;
  String? _errorMessage;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
    _loadGigs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (_) {
      // Categories are optional for filtering; fail silently
    }
  }

  Future<void> _loadGigs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _searchController.text.trim();
      final results = await Future.wait([
        _gigRepository.getActiveGigs(
          page: _currentPage,
          size: _pageSize,
          query: query.isNotEmpty ? query : null,
          categoryId: _selectedCategoryId,
        ),
        _gigRepository.getActiveGigsTotalPages(
          size: _pageSize,
          query: query.isNotEmpty ? query : null,
          categoryId: _selectedCategoryId,
        ),
      ]);

      if (mounted) {
        setState(() {
          _gigs = results[0] as List<ServiceGigResponseDto>;
          _totalPages = results[1] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load services. Please try again.';
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _currentPage = 0;
      _loadGigs();
    });
  }

  void _onCategoryChanged(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _currentPage = 0;
    });
    _loadGigs();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadGigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceSnow,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Services', style: AppTextStyles.headingMd),
        centerTitle: false,
        surfaceTintColor: AppColors.surfaceSnow,
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ──
          _buildSearchFilter(),

          // ── Content ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadGigs,
              color: AppColors.accent600,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSnow,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceIce200),
        ),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
            decoration: InputDecoration(
              hintText: 'Search services...',
              hintStyle:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.neutral400),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.neutral400),
                      onPressed: () {
                        _searchController.clear();
                        _currentPage = 0;
                        _loadGigs();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceIce100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.accent600, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          const SizedBox(height: 12),

          // Category filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _selectedCategoryId == null,
                  onTap: () => _onCategoryChanged(null),
                ),
                ..._categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildFilterChip(
                        label: cat.name,
                        isSelected: _selectedCategoryId == cat.id,
                        onTap: () => _onCategoryChanged(cat.id),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent600 : AppColors.surfaceIce100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent600 : AppColors.surfaceIce200,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.surfaceSnow : AppColors.neutral600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_gigs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        ..._gigs.map((gig) => ServiceGigCard(gig: gig)),
        PaginationControls(
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChanged: _onPageChanged,
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerCard(height: 160),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadGigs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent600,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_off_rounded,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: AppTextStyles.headingMd.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
