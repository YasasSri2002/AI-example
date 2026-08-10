import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/booking_dto.dart';
import '../../../data/repositories/booking_repository.dart';

/// Full-screen booking form screen.
///
/// Allows the user to book a service gig by filling in contact details,
/// selecting a date and time, and adding additional information.
/// Submit calls [BookingRepository.createBooking].
class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.gigId,
    required this.providerId,
    this.providerName,
    this.gigTitle,
  });

  final String gigId;
  final String providerId;
  final String? providerName;
  final String? gigTitle;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingRepository _bookingRepository = BookingRepository();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.accent600,
            onPrimary: AppColors.surfaceSnow,
            onSurface: AppColors.neutral800,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.accent600,
            onPrimary: AppColors.surfaceSnow,
            onSurface: AppColors.neutral800,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() => _errorMessage = 'Please select a starting date');
      return;
    }
    if (_selectedTime == null) {
      setState(() => _errorMessage = 'Please select a starting time');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final booking = BookingRequestDto(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        contactNo: _contactController.text.trim(),
        address: _addressController.text.trim(),
        additionalInformation: _additionalInfoController.text.trim(),
        startingTime: _selectedTime!.format(context),
        startingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        providerId: widget.providerId,
        gigId: widget.gigId,
      );

      final result = await _bookingRepository.createBooking(booking);

      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking submitted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to submit booking. Please try again.';
  }

  String _getDateLabel() {
    if (_selectedDate == null) return 'Select date';
    return DateFormat('EEE, MMM d, y').format(_selectedDate!);
  }

  String _getTimeLabel() {
    if (_selectedTime == null) return 'Select time';
    return _selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceSnow,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: AppColors.surfaceSnow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral800),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        title: Text('Book Service', style: AppTextStyles.headingMd),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                if (widget.gigTitle != null)
                  Text(
                    widget.gigTitle!,
                    style: AppTextStyles.headingLg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.providerName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'with ${widget.providerName}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Name ──
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (v) => Validators.required(v, 'Full name'),
                ),

                // ── Email ──
                _buildTextFormField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                // ── Contact ──
                _buildTextFormField(
                  controller: _contactController,
                  label: 'Contact Number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),

                // ── Address ──
                _buildTextFormField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_rounded,
                  maxLines: 3,
                  validator: (v) => Validators.required(v, 'Address'),
                ),

                // ── Date & Time Pickers ──
                Row(
                  children: [
                    // Date picker
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Date',
                        value: _getDateLabel(),
                        onTap: _isSubmitting ? null : _pickDate,
                        hasError: hasError && _selectedDate == null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Time picker
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Time',
                        value: _getTimeLabel(),
                        onTap: _isSubmitting ? null : _pickTime,
                        hasError: hasError && _selectedTime == null,
                      ),
                    ),
                  ],
                ),

                // ── Additional Information ──
                _buildTextFormField(
                  controller: _additionalInfoController,
                  label: 'Additional Information (optional)',
                  icon: Icons.note_rounded,
                  maxLines: 4,
                  validator: (_) => null, // optional field
                ),

                // ── Error Message ──
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Submit Button ──
                FilledButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent600,
                    foregroundColor: AppColors.surfaceSnow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surfaceSnow,
                          ),
                        )
                      : Text(
                          'Confirm Booking',
                          style: AppTextStyles.button,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.accent600, size: 20),
          filled: true,
          fillColor: AppColors.surfaceIce100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent600, width: 2),
          ),
          labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral600),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        enabled: !_isSubmitting,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback? onTap,
    bool hasError = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceIce100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.neutral200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
