import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_dto.dart';
import '../../../data/models/provider_dto.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/provider_repository.dart';

import '../../../shared/widgets/app_navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/popular_providers_list.dart';

/// The main landing page of the application.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProviderRepository _providerRepository = ProviderRepository();
  
  List<CategoryResponseDto> _categories = [];
  List<ProviderWithCategory> _popularProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _categoryRepository.getAllCategories(),
        _providerRepository.getPopularProviders(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryResponseDto>;
          _popularProviders = results[1] as List<ProviderWithCategory>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSearch(String query, String? categoryId) {
    final params = <String, dynamic>{};
    if (query.isNotEmpty) params['query'] = query;
    if (categoryId != null) params['category'] = categoryId;
    
    // Navigate to gigs list screen with search parameters
    context.push(
      Uri(
        path: '/service-gigs',
        queryParameters: params,
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent600,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section with Search
              HeroSection(
                categories: _categories,
                onSearch: _handleSearch,
              ),
              
              const SizedBox(height: 48),
              
              // Popular Providers List
              PopularProvidersList(
                providers: _popularProviders,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
