import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_page.dart';
import '../features/auth/login_page.dart';
import '../features/checklists/checklist_run_page.dart';
import '../features/home/home_page.dart';
import '../features/incidents/incidents_page.dart';
import '../features/incidents/new_incident_page.dart';
import '../features/manuals/manuals_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/scorecard/scorecard_page.dart';
import '../features/sops/sop_detail_page.dart';
import '../features/tasks/tasks_page.dart';
import '../features/tasks/new_task_page.dart';
import '../data/firebase/firebase_providers.dart';
import '../features/shared/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(ref.read(firebaseAuthProvider).authStateChanges()),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.path == '/login';
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/manuals',
        builder: (context, state) => const ManualsPage(),
      ),
      GoRoute(
        path: '/sops/:id',
        builder: (context, state) => SopDetailPage(sopId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checklists/run/:id',
        builder: (context, state) => ChecklistRunPage(checklistId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/incidents',
        builder: (context, state) => const IncidentsPage(),
      ),
      GoRoute(
        path: '/incidents/new',
        builder: (context, state) => const NewIncidentPage(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const NewTaskPage(),
      ),
      GoRoute(
        path: '/scorecard',
        builder: (context, state) => const ScorecardPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
