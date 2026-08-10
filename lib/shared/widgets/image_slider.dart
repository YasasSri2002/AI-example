import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

/// A horizontal carousel widget using PageView with dot indicators.
class ImageSlider extends StatefulWidget {
  const ImageSlider({
    super.key,
    required this.imageUrls,
    this.height = 200,
  });

  final List<String> imageUrls;
  final double height;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        color: AppColors.surfaceIce100,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded, color: AppColors.neutral400),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceIce100,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.accent600),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceIce100,
                  child: const Center(
                    child: Icon(Icons.error_outline_rounded, color: AppColors.error),
                  ),
                ),
              );
            },
          ),
          
          // Dot Indicators
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.accent600
                          : AppColors.surfaceSnow.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
