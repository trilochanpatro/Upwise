import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/upwise_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../onboarding/models/onboarding_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onRestartOnboarding,
    required this.onSignOut,
    this.onClearAiMemory,
  });

  final OnboardingProfile? profile;
  final VoidCallback onRestartOnboarding;
  final Future<void> Function() onSignOut;
  final Future<void> Function()? onClearAiMemory;

  void _showAiMemoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology_alt_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('AI Memory & Facts'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upwise AI remembers these confirmed details to give you tailored coaching:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _memoryFact(
                'Life stage',
                profile?.lifeStage.isNotEmpty == true
                    ? profile!.lifeStage
                    : 'Employed professional'),
            _memoryFact(
                'Top priority',
                profile?.primaryGoalArea.isNotEmpty == true
                    ? profile!.primaryGoalArea
                    : 'Career and Skill Growth'),
            _memoryFact(
                'Daily availability',
                profile?.dailyTimeCommitment.isNotEmpty == true
                    ? profile!.dailyTimeCommitment
                    : '45 mins/day'),
            _memoryFact(
                'Coaching tone',
                profile?.preferredStyle.isNotEmpty == true
                    ? profile!.preferredStyle
                    : 'Action-oriented'),
            const SizedBox(height: 12),
            const Text(
              'You can clear or redact memory anytime in compliance with your privacy rights.',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (onClearAiMemory != null) {
                await onClearAiMemory!();
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI memory and chat cleared.')),
              );
            },
            child: const Text('Clear Memory',
                style: TextStyle(color: AppColors.error)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _memoryFact(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = profile?.lifeStage.isNotEmpty == true
        ? profile!.lifeStage
        : "Upwise Explorer";
    final focus = profile?.primaryGoalArea.isNotEmpty == true
        ? profile!.primaryGoalArea
        : "Personal Mastery";

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const SectionHeader(
          title: 'Profile & Settings',
          subtitle: 'Manage context, AI memory, and privacy controls',
        ),
        const SizedBox(height: 8),

        // User Overview Header Card
        UpwiseCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Priority: $focus',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Settings items
        UpwiseCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.psychology_alt_outlined,
                    color: AppColors.primary),
                title: const Text('AI Coach Memory',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text(
                    'Review what the coach remembers about you',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showAiMemoryDialog(context),
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                leading: const Icon(Icons.explore_outlined,
                    color: AppColors.primary),
                title: const Text('Redo Discovery Onboarding',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text(
                    'Update life situation, targets, and time limits',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.replay, size: 20),
                onTap: onRestartOnboarding,
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.primary),
                title: const Text('Notifications & Focus Blocks',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Quiet hours, morning check-in at 8:30 AM',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notification preferences saved.')),
                  );
                },
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                leading: const Icon(Icons.security_outlined,
                    color: AppColors.primary),
                title: const Text('Privacy & Data Governance',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Synced securely to your Upwise account',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Your goals and tasks sync to your account.')),
                  );
                },
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
                onTap: () async {
                  try {
                    await onSignOut();
                  } on AuthException catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message)),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // App Version and Blueprint Note
        Center(
          child: Column(
            children: [
              const Text(
                'Upwise MVP v0.1.0 (Android Starter)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary),
              ),
              const SizedBox(height: 4),
              Text(
                'Connected Supabase + FastAPI backend active',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
