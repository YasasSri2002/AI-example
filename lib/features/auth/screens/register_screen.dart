import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Registration screen with Client/Provider toggle.
///
/// Client registration calls `POST /users/register`.
/// Provider registration calls `POST /provider/persist`.
/// Uses form validation via [Validators].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProvider = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactNoController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final endpoint = _isProvider
          ? ApiConstants.providerPersist
          : ApiConstants.usersRegister;

      final Map<String, dynamic> body = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      if (_isProvider) {
        body['contactNo'] = _contactNoController.text.trim();
      }

      if (ApiConstants.useMockApi) {
        // Simulate network latency for the demo.
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        _showSuccessDialog();
        return;
      }

      final response = await DioClient.instance.post(endpoint, data: body);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 56,
        ),
        title: Text('Registration Successful!', style: AppTextStyles.headingMd),
        content: Text(
          _isProvider
              ? 'Your provider account has been created. You can now login.'
              : 'Your account has been created. You can now login.',
          style: AppTextStyles.bodyMd,
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/login');
              },
              child: const Text('Go to Login'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back Button ──
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceSnow,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Header ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
                        style: AppTextStyles.headingXl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join Nestify today',
                        style: AppTextStyles.bodyMd,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Client/Provider Toggle ──
                _buildToggle(),
                const SizedBox(height: 24),

                // ── Registration Form Card ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSnow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // First Name & Last Name Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    Validators.required(v, 'First name'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    Validators.required(v, 'Last name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Username
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.alternate_email_rounded,
                          validator: (v) =>
                              Validators.minLength(v, 3, 'Username'),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.neutral400,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordController.text),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.neutral400,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ),

                        // Contact Number (Provider only)
                        if (_isProvider) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _contactNoController,
                            label: 'Contact Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.surfaceSnow,
                                    ),
                                  )
                                : Text(
                                    _isProvider
                                        ? 'Register as Provider'
                                        : 'Register as Client',
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Login Link ──
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodySm,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text('Login', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Widget Builders
  // ──────────────────────────────────────────────

  /// Client/Provider toggle.
  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceIce100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleOption('Client', !_isProvider, () {
            setState(() => _isProvider = false);
          }),
          _toggleOption('Provider', _isProvider, () {
            setState(() => _isProvider = true);
          }),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent500 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.accent600.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive
                    ? AppColors.surfaceSnow
                    : AppColors.neutral600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.neutral400, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
