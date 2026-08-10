import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: NestifyApp(),
    ),
  );
}

/// Root widget for the Nestify app.
///
/// Wrapped in [ProviderScope] for Riverpod state management.
/// Uses [MaterialApp.router] with [GoRouter] and [AppTheme].
class NestifyApp extends StatefulWidget {
  const NestifyApp({super.key});

  @override
  State<NestifyApp> createState() => _NestifyAppState();
}

class _NestifyAppState extends State<NestifyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nestify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
    );
  }
}
