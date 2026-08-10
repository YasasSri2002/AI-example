import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_dto.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'bookings_screen.dart';

/// Profile dashboard screen with tabbed navigation.
///
/// Tabs: Dashboard (default), Security, Bookings, Preferences.
/// The Dashboard tab shows account info, an editable personal information
/// form, profile photo, and a logout button.
class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final UserRepository _userRepository = UserRepository();
  final AuthRepository _authRepository = AuthRepository();

  UserResponseDto? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers for the personal info form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userRepository.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        _populateControllers(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile data.';
        });
      }
    }
  }

  void _populateControllers(UserResponseDto? user) {
    if (user == null) return;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _usernameController.text = user.username ?? '';
    _contactController.text = user.contact ?? '';
    _addressController.text = user.address ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final updatedUser = UserResponseDto(
      id: _currentUser!.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      contact: _contactController.text.trim(),
      address: _addressController.text.trim(),
      email: _currentUser!.email,
      paymentMethod: _currentUser!.paymentMethod,
      createdAt: _currentUser!.createdAt,
    );

    try {
      final result = await _userRepository.updateUser(updatedUser);
      if (mounted) {
        setState(() {
          _currentUser = result ?? updatedUser;
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update profile.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    // Navigate to login
    if (mounted) {
      Navigator.of(context)
        ..popUntil((route) => route.isFirst)
        ..pushReplacementNamed('/login');
    }
  }

  /// Builds initials string from first and last name.
  String _buildInitials(String? firstName, String? lastName) {
    final first =
        firstName != null && firstName.isNotEmpty ? firstName.substring(0, 1) : '';
    final last =
        lastName != null && lastName.isNotEmpty ? lastName.substring(0, 1) : '';
    return '$first$last';
  }

  Future<void> _refreshProfile() async {
    await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading profile...');
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with Tabs ──
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.surfaceSnow,
            surfaceTintColor: AppColors.surfaceSnow,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.neutral800),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('My Profile', style: AppTextStyles.headingMd),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.accent600,
              unselectedLabelColor: AppColors.neutral600,
              indicatorColor: AppColors.accent600,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Security'),
                Tab(text: 'Bookings'),
                Tab(text: 'Preferences'),
              ],
            ),
          ),

          // ── Tab Content ──
          SliverToBoxAdapter(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 120,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildSecurityTab(),
          const BookingsScreen(),
          _buildPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final user = _currentUser;
    final joinDate = user?.createdAt != null
        ? DateFormat('MMM d, y').format(DateTime.parse(user!.createdAt!))
        : '—';

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: AppColors.accent600,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile Header ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.profileGradient,
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
              child: Column(
                children: [
                  // Profile photo
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceIce100,
                        child: user != null &&
                                user.firstName != null &&
                                user.firstName!.isNotEmpty
                            ? Text(
                                _buildInitials(user.firstName, user.lastName),
                                style: AppTextStyles.headingXl.copyWith(
                                  color: AppColors.neutral800,
                                ),
                              )
                            : const Icon(Icons.person_rounded,
                                size: 40, color: AppColors.neutral400),
                      ),
                      if (_isEditing)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent600,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surfaceSnow, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: AppColors.surfaceSnow),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Unknown User',
                    style: AppTextStyles.headingLg,
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.neutral600),
                  ),
                  Text(
                    'Member since $joinDate',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Edit Toggle ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Personal Information',
                    style: AppTextStyles.headingSm),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        // Reset controllers
                        _populateControllers(_currentUser);
                      }
                    });
                  },
                  icon: Icon(
                    _isEditing
                        ? Icons.close_rounded
                        : Icons.edit_rounded,
                    size: 18,
                    color: AppColors.accent600,
                  ),
                  label: Text(
                    _isEditing ? 'Cancel' : 'Edit',
                    style: AppTextStyles.label.copyWith(color: AppColors.accent600),
                  ),
                ),
              ],
            ),

            // ── Personal Info Form ──
            _buildPersonalInfoForm(),

            const SizedBox(height: 24),

            // ── Logout Button ──
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _logout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Logout',
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildPersonalInfoForm() {
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
      child: Column(
        children: [
          _buildInfoField('First Name', _firstNameController),
          _buildInfoField('Last Name', _lastNameController),
          _buildInfoField('Username', _usernameController),
          _buildInfoField('Contact', _contactController),
          _buildInfoField('Address', _addressController, maxLines: 2),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surfaceSnow,
                        ),
                      )
                    : Text('Save Changes', style: AppTextStyles.button),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          _isEditing
              ? TextFormField(
                  controller: controller,
                  enabled: !_isSaving,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceIce100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.accent600, width: 2),
                    ),
                  ),
                )
              : Text(
                  controller.text.isEmpty ? '—' : controller.text,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.neutral800),
                ),
        ],
      ),
    );
  }

  /// Placeholder Security tab — expanded in Shot 9.
  Widget _buildSecurityTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text('Security settings coming soon',
                style: AppTextStyles.headingMd
                    .copyWith(color: AppColors.neutral600)),
            const SizedBox(height: 8),
            Text('Password update and 2FA will be available here.',
                style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// Placeholder Preferences tab — expanded in Shot 9.
  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_outlined,
                size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text('Notification preferences coming soon',
                style: AppTextStyles.headingMd
                    .copyWith(color: AppColors.neutral600)),
            const SizedBox(height: 8),
            Text('Configure your notification settings here.',
                style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
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
              onPressed: _loadUser,
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
}
