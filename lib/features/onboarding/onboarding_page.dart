import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/providers.dart';
import '../shared/app_state.dart';
import '../shared/auth_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(10, (_) => TextEditingController());
  String _industryKey = 'hospitality_kitchen';
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final answers = <String, dynamic>{
      for (var i = 0; i < _controllers.length; i++) 'q${i + 1}': _controllers[i].text,
    };
    final orgId = ref.read(activeOrgIdProvider);
    final orgRepo = ref.read(orgRepositoryProvider);
    final aiRepo = ref.read(aiGenerationRepositoryProvider);

    await orgRepo.createOrgSetup(orgId, _industryKey, answers);
    await aiRepo.generateStarterPack(orgId: orgId, industryKey: _industryKey, answers: answers);

    if (mounted) {
      context.go('/home');
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStream = ref.watch(orgRepositoryProvider).watchSubscription(ref.watch(activeOrgIdProvider));
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: StreamBuilder(
        stream: subscriptionStream,
        builder: (context, snapshot) {
          final creditsRemaining = snapshot.data?.aiCreditsRemaining ?? 0;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Select your industry pack to generate starter SOPs and checklists.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _industryKey,
                    items: const [
                      DropdownMenuItem(
                        value: 'hospitality_kitchen',
                        child: Text('Hospitality - Multi-site Kitchen'),
                      ),
                      DropdownMenuItem(
                        value: 'retail_ops',
                        child: Text('Retail - Store Operations'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _industryKey = value ?? 'hospitality_kitchen'),
                    decoration: const InputDecoration(labelText: 'Industry Pack'),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < _controllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _controllers[i],
                        decoration: InputDecoration(labelText: 'Question ${i + 1}'),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (creditsRemaining <= 0)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.lock),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI credits depleted. Upgrade your plan to generate industry packs.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: creditsRemaining <= 0 || _submitting || userId == null ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Generate Starter Pack'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
