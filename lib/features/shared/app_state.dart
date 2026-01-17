import 'package:flutter_riverpod/flutter_riverpod.dart';

const demoOrgId = 'demo-org';

final activeOrgIdStateProvider = StateProvider<String>((ref) => demoOrgId);
final activeOrgIdProvider = Provider<String>((ref) => ref.watch(activeOrgIdStateProvider));
