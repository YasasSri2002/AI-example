import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_dto.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../booking/widgets/booking_card.dart';

/// Screen displaying all bookings for the current client.
///
/// Uses [BookingCard] to render each booking with action buttons
/// for cancelling, rescheduling, and marking as complete.
/// Supports pull-to-refresh and loading/error/empty states.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingRepository _bookingRepository = BookingRepository();

  List<BookingResponseDto> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await _bookingRepository.getBookingsByClient();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load bookings. Please try again.';
        });
      }
    }
  }

  Future<void> _handleCancel(BookingResponseDto booking) async {
    try {
      await _bookingRepository.cancelBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel booking.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleMarkComplete(BookingResponseDto booking) async {
    try {
      await _bookingRepository.markComplete(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking marked as complete'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to mark booking.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleReschedule(BookingResponseDto booking) {
    // TODO: Implement reschedule modal (Shot 9 — Section 2.6)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reschedule coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your bookings...');
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.accent600,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return BookingCard(
            key: ValueKey(booking.id),
            booking: booking,
            onCancel: () => _handleCancel(booking),
            onMarkComplete: () => _handleMarkComplete(booking),
            onReschedule: () => _handleReschedule(booking),
          );
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
              onPressed: _loadBookings,
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
            const Icon(Icons.book_outlined,
                size: 80, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: AppTextStyles.headingMd
                  .copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse services and book your first appointment.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to gigs list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to services')),
                );
              },
              icon: const Icon(Icons.search_rounded),
              label: Text('Browse Services',
                  style: AppTextStyles.button),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
