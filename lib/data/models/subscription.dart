class Subscription {
  const Subscription({
    required this.orgId,
    required this.plan,
    required this.seats,
    required this.sitesLimit,
    required this.aiCreditsMonthly,
    required this.aiCreditsRemaining,
    required this.status,
  });

  final String orgId;
  final String plan;
  final int seats;
  final int sitesLimit;
  final int aiCreditsMonthly;
  final int aiCreditsRemaining;
  final String status;

  factory Subscription.fromMap(Map<String, dynamic> data) {
    return Subscription(
      orgId: data['orgId'] as String? ?? '',
      plan: data['plan'] as String? ?? 'STARTER',
      seats: data['seats'] as int? ?? 0,
      sitesLimit: data['sitesLimit'] as int? ?? 1,
      aiCreditsMonthly: data['aiCreditsMonthly'] as int? ?? 0,
      aiCreditsRemaining: data['aiCreditsRemaining'] as int? ?? 0,
      status: data['status'] as String? ?? 'INACTIVE',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'plan': plan,
      'seats': seats,
      'sitesLimit': sitesLimit,
      'aiCreditsMonthly': aiCreditsMonthly,
      'aiCreditsRemaining': aiCreditsRemaining,
      'status': status,
    };
  }
}
