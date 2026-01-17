import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _loading = false;

  Future<void> _signInDemo() async {
    setState(() => _loading = true);
    final auth = FirebaseAuth.instance;
    final credential = await auth.signInAnonymously();
    final user = credential.user;
    if (user != null) {
      await ref.read(orgRepositoryProvider).ensureUserProfile(
            orgId: ref.read(activeOrgIdProvider),
            userId: user.uid,
            fullName: 'Demo Operator',
            role: 'OWNER',
            siteId: 'site-1',
          );
    }
    if (mounted) {
      context.go('/home');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'OpsManual AI',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text('Sign in to your operations workspace.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signInDemo,
                child: _loading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Continue with Demo Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : () => context.go('/onboarding'),
                child: const Text('Start Onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
