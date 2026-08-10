import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// Note: A real AuthProvider will be needed later to determine auth state.
// For now, we mock the auth state or assume guest.

/// The top application navigation bar.
class AppNavbar extends ConsumerWidget implements PreferredSizeWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: read auth state from a provider
    // ignore: dead_code
    const bool isAuthenticated = false; 

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_work_rounded, color: AppColors.accent600),
          const SizedBox(width: 8),
          Text(
            'Nestify',
            style: AppTextStyles.headingMd.copyWith(
              color: AppColors.primary900,
            ),
          ),
        ],
      ),
      actions: [
        if (!isAuthenticated)
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login'),
          ),
        if (isAuthenticated)
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.push('/users/profile/me'), // placeholder route
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
