import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/ui_feedback_provider.dart';
import 'presentation/screens/shell/app_shell.dart';
import 'presentation/widgets/momentum_splash.dart';

/// Two routes: the shell, and a deep link that hands a task id to the shell.
/// `/task/:id` redirects rather than pushing a page, so a notification tap
/// opens the detail sheet over whatever tab was already showing.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const MomentumSplash(child: AppShell()),
      ),
      GoRoute(
        path: '/task/:id',
        redirect: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id != null) {
            // Deferred: mutating provider state during a redirect would run
            // inside a build.
            Future.microtask(
              () => ref.read(pendingTaskIdProvider.notifier).state = id,
            );
          }
          return '/';
        },
      ),
    ],
  );
});

class MomentumApp extends ConsumerWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
