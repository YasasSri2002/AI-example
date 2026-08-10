import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_dto.dart';

/// A card widget for displaying a single booking.
///
/// Shows service gig info, provider details, status badge, date/time,
/// and conditional action buttons (Cancel, Reschedule, Mark Complete).
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onReschedule,
    this.onMarkComplete,
  });

  final BookingResponseDto booking;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final status = _BookingStatusDisplay.fromString(booking.status);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: Status Badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: status.bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${booking.id.substring(0, 8)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.bgColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: status.color),
                    ),
                    child: Text(
                      status.label,
                      style: AppTextStyles.caption.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body: Service & Provider ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service gig title
                  if (booking.serviceGigResponseDto != null) ...[
                    Text(
                      booking.serviceGigResponseDto!.title,
                      style: AppTextStyles.headingSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.serviceGigResponseDto!.description ??
                          'No description',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else
                    Text(
                      'Service Booking',
                      style: AppTextStyles.headingSm,
                    ),

                  const SizedBox(height: 12),

                  // Date & Time row
                  if (booking.startingDate != null ||
                      booking.startingTime != null) ...[
                    Row(
                      children: [
                        if (booking.startingDate != null) ...[
                          _buildDateBadge(booking.startingDate!),
                          const SizedBox(width: 8),
                        ],
                        if (booking.startingTime != null) ...[
                          _buildTimeBadge(booking.startingTime!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Provider info
                  if (booking.providerDto != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceIce100,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: AppColors.accent400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.providerDto!.fullName,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                booking.providerDto!.expertise ??
                                    'Professional',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.neutral600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons (conditionally shown based on status)
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildDateBadge(String dateStr) {
    final parsed = _parseDate(dateStr);
    final formatted = parsed != null
        ? DateFormat('MMM d, y').format(parsed)
        : dateStr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceIce100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: AppColors.neutral600,
          ),
          const SizedBox(width: 4),
          Text(
            formatted,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String timeStr) {
    final formatted = timeStr.contains(':')
        ? timeStr.substring(0, timeStr.length.clamp(0, 5))
        : timeStr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceIce100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 12,
            color: AppColors.neutral600,
          ),
          const SizedBox(width: 4),
          Text(
            formatted,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final statusDisplay = _BookingStatusDisplay.fromString(booking.status);
    final isPending = statusDisplay.status == _Status.pending;
    final bool canCancel = isPending;
    final bool canComplete = isPending;
    final bool canReschedule = isPending;

    if (!canCancel && !canReschedule && !canComplete) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (canComplete) ...[
          Expanded(
            child: _ActionButton(
              label: 'Mark Complete',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
              onTap: onMarkComplete,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (canReschedule) ...[
          Expanded(
            child: _ActionButton(
              label: 'Reschedule',
              icon: Icons.schedule_rounded,
              color: AppColors.accent600,
              onTap: onReschedule,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (canCancel) ...[
          Expanded(
            child: _ActionButton(
              label: 'Cancel',
              icon: Icons.cancel_outlined,
              color: AppColors.error,
              onTap: onCancel,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small reusable action button used inside [BookingCard].
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label not implemented yet'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal enum mapping booking status string to display properties.
enum _Status {
  pending,
  completed,
  cancelled,
}

/// Display metadata for a booking status.
class _BookingStatusDisplay {
  _BookingStatusDisplay({
    required this.status,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final _Status status;
  final String label;
  final Color color;
  final Color bgColor;

  factory _BookingStatusDisplay.fromString(String raw) {
    final lower = raw.toLowerCase();
    if (lower == 'completed') {
      return _BookingStatusDisplay(
        status: _Status.completed,
        label: 'Completed',
        color: AppColors.success,
        bgColor: AppColors.successBg,
      );
    }
    if (lower == 'cancelled') {
      return _BookingStatusDisplay(
        status: _Status.cancelled,
        label: 'Cancelled',
        color: AppColors.error,
        bgColor: AppColors.errorBg,
      );
    }
    // Default: pending
    return _BookingStatusDisplay(
      status: _Status.pending,
      label: 'Pending',
      color: AppColors.warning,
      bgColor: AppColors.warningBg,
    );
  }
}
