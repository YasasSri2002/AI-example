import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth_repository.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/login_callback_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/service_gigs/screens/gigs_list_screen.dart';
import '../features/service_gigs/screens/gig_detail_screen.dart';
import '../features/providers/screens/providers_list_screen.dart';
import '../features/providers/screens/provider_detail_screen.dart';
import '../features/booking/screens/booking_form_screen.dart';
import '../features/user_profile/screens/profile_dashboard_screen.dart';
import '../features/user_profile/screens/bookings_screen.dart';

/// Nestify app router configuration using [GoRouter].
///
/// Defines all public and protected routes with role-based guards.
/// Uses a [ShellRoute] for the bottom navigation bar on authenticated screens.
class AppRouter {
  AppRouter({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  /// Navigational shell key for the bottom navigation.
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: [
      // ── Shell Route with Bottom Navigation ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithBottomNav(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Service Gigs
          GoRoute(
            path: '/service-gigs',
            name: 'service-gigs',
            builder: (context, state) => GigsListScreen(
              initialQuery: state.uri.queryParameters['query'],
              initialCategoryId: state.uri.queryParameters['category'],
            ),
            routes: [
              GoRoute(
                path: 'details/:id',
                name: 'gig-detail',
                builder: (context, state) => GigDetailScreen(
                  gigId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Providers
          GoRoute(
            path: '/providers',
            name: 'providers',
            builder: (context, state) =>
                const ProvidersListScreen(),
            routes: [
              GoRoute(
                path: 'details/:id',
                name: 'provider-detail',
                builder: (context, state) => ProviderDetailScreen(
                  providerId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'dashboard',
                name: 'provider-dashboard',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Provider Dashboard'),
              ),
            ],
          ),

          // About
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'About'),
          ),
        ],
      ),

      // ── Booking Form (accessed from gig detail) ──
      GoRoute(
        path: '/booking-form',
        name: 'booking-form',
        builder: (context, state) => BookingFormScreen(
          gigId: state.uri.queryParameters['gigId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          providerName: state.uri.queryParameters['providerName'],
          gigTitle: state.uri.queryParameters['gigTitle'],
        ),
      ),

      // ── Auth Routes (outside shell — no bottom nav) ──
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        name: 'login-callback',
        builder: (context, state) => LoginCallbackScreen(
          code: state.uri.queryParameters['code'],
        ),
      ),

      // ── User Profile Routes (protected: user | admin) ──
      GoRoute(
        path: '/users/profile/:id',
        name: 'user-profile',
        builder: (context, state) => ProfileDashboardScreen(
          userId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'security',
            name: 'user-security',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Security'),
          ),
          GoRoute(
            path: 'booking',
            name: 'user-bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: 'preferences',
            name: 'user-preferences',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Preferences'),
          ),
        ],
      ),

      // ── Admin Routes (protected: admin) ──
      GoRoute(
        path: '/site-admin',
        name: 'admin-dashboard',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Admin Dashboard'),
        routes: [
          GoRoute(
            path: 'users',
            name: 'admin-users',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Admin - Users'),
          ),
          GoRoute(
            path: 'providers',
            name: 'admin-providers',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Admin - Providers'),
          ),
          GoRoute(
            path: 'booking',
            name: 'admin-bookings',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Admin - Bookings'),
          ),
        ],
      ),

      // ── Forbidden ──
      GoRoute(
        path: '/forbidden',
        name: 'forbidden',
        builder: (context, state) =>
            const _PlaceholderScreen(title: '403 Forbidden'),
      ),
    ],
  );

  // ──────────────────────────────────────────────
  // Global Redirect Guard
  // ──────────────────────────────────────────────

  Future<String?> _globalRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.uri.path;

    // Public routes — no auth required
    final publicPaths = [
      '/',
      '/service-gigs',
      '/providers',
      '/about',
      '/login',
      '/register',
      '/login-callback',
      '/forbidden',
    ];

    // Check if it's a public route or sub-route of a public route
    final isPublic = publicPaths.contains(path) ||
        path.startsWith('/service-gigs/details/') ||
        path.startsWith('/providers/details/');

    if (isPublic) return null;

    // Check authentication
    final isAuth = await _authRepository.isAuthenticated();
    if (!isAuth) return '/login';

    // Role-based access
    final roles = await _authRepository.getUserRoles();

    // User profile routes
    if (path.startsWith('/users/profile')) {
      if (roles.contains('user') || roles.contains('admin')) {
        return null;
      }
      return '/forbidden';
    }

    // Provider dashboard
    if (path.startsWith('/providers/dashboard')) {
      if (roles.contains('provider') || roles.contains('admin')) {
        return null;
      }
      return '/forbidden';
    }

    // Admin routes
    if (path.startsWith('/site-admin')) {
      if (roles.contains('admin')) {
        return null;
      }
      return '/forbidden';
    }

    return null;
  }
}

// ──────────────────────────────────────────────
// Shell Scaffold with Bottom Navigation
// ──────────────────────────────────────────────

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Providers',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/service-gigs')) return 1;
    if (location.startsWith('/providers')) return 2;
    if (location.startsWith('/about')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/service-gigs');
        break;
      case 2:
        context.go('/providers');
        break;
      case 3:
        // For now, go to About. Will be replaced with profile later.
        context.go('/about');
        break;
    }
  }
}

// ──────────────────────────────────────────────
// Placeholder Screen (replaced in later shots)
// ──────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
