import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';

/// Handles the OAuth callback after Keycloak redirects back to the app.
///
/// Shows a loading spinner while exchanging the authorization code
/// for tokens. Redirects to home on success, or shows an error with retry.
class LoginCallbackScreen extends StatefulWidget {
  const LoginCallbackScreen({
    super.key,
    this.code,
  });

  /// The authorization code from Keycloak redirect.
  final String? code;

  @override
  State<LoginCallbackScreen> createState() => _LoginCallbackScreenState();
}

class _LoginCallbackScreenState extends State<LoginCallbackScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _exchangeToken();
  }

  Future<void> _exchangeToken() async {
    if (widget.code == null || widget.code!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No authorization code received.';
      });
      return;
    }

    try {
      final success = await _authRepository.handleCallback(widget.code!);

      if (!mounted) return;

      if (success) {
        context.go('/');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to exchange token. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication error: $e';
      });
    }
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
          child: Center(
            child: _isLoading ? _buildLoading() : _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.accent600,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Authenticating...',
          style: AppTextStyles.headingMd,
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we verify your credentials',
          style: AppTextStyles.bodySm,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Authentication Failed',
            style: AppTextStyles.headingMd.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'An unknown error occurred.',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _exchangeToken();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}
