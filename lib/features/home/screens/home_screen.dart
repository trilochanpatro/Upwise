import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/upwise_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../tasks/models/task_model.dart';
import '../../onboarding/models/onboarding_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onAddTask,
    this.onDeleteTask,
    this.dailyInsight,
    this.profile,
  });

  final List<TaskModel> tasks;
  final Future<void> Function(int index) onToggleTask;
  final Future<bool> Function(String title, String category, int minutes)
      onAddTask;
  final Future<void> Function(int index)? onDeleteTask;
  final String? dailyInsight;
  final OnboardingProfile? profile;

  Future<void> _showQuickAddDialog(BuildContext context) async {
    final titleController = TextEditingController();
    String category = 'Focus';
    int minutes = 25;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Daily Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What needs to get done?',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Category:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: category,
                    items: const [
                      DropdownMenuItem(value: 'Career', child: Text('Career')),
                      DropdownMenuItem(value: 'Skills', child: Text('Skills')),
                      DropdownMenuItem(value: 'Focus', child: Text('Focus')),
                      DropdownMenuItem(value: 'Health', child: Text('Health')),
                      DropdownMenuItem(
                          value: 'Personal', child: Text('Personal')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Duration:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: minutes,
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('15 mins')),
                      DropdownMenuItem(value: 25, child: Text('25 mins')),
                      DropdownMenuItem(value: 45, child: Text('45 mins')),
                      DropdownMenuItem(value: 60, child: Text('60 mins')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => minutes = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final text = titleController.text.trim();
                if (text.isNotEmpty) {
                  final saved = await onAddTask(text, category, minutes);
                  if (saved && ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Add Priority'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    final focusArea = profile?.primaryGoalArea.isNotEmpty == true
        ? profile!.primaryGoalArea
        : "Career and Personal Mastery";

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Daily Greeting Header
        Text(
          'YOUR DAILY OVERVIEW',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Make progress that matters.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Focus anchor: $focusArea',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),

        // Progress Execution Card
        UpwiseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's execution",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBar(
                value: progress,
                height: 8,
                color: AppColors.primary,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount of $totalCount priorities completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (completedCount == totalCount && totalCount > 0)
                    const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'All done for today!',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Priorities List Section
        SectionHeader(
          title: "Today's priorities",
          subtitle: "Clear, sequential steps to avoid cognitive fatigue",
          action: IconButton.filledTonal(
            tooltip: 'Add Priority',
            onPressed: () => _showQuickAddDialog(context),
            icon: const Icon(Icons.add, size: 20),
          ),
        ),

        if (tasks.isEmpty)
          const UpwiseCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No priorities set for today. Tap + to add one!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...List.generate(tasks.length, (i) {
            final task = tasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UpwiseCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                backgroundColor:
                    task.isCompleted ? const Color(0xFFFBFBFE) : Colors.white,
                borderColor:
                    task.isCompleted ? AppColors.borderLight : AppColors.border,
                child: Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onChanged: (_) => onToggleTask(i),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.schedule,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 3),
                              Text(
                                '${task.estimatedMinutes}m',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onDeleteTask != null)
                      IconButton(
                        tooltip: 'Remove priority',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close,
                            size: 18, color: AppColors.textTertiary),
                        onPressed: () => onDeleteTask!(i),
                      ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 18),

        // AI Daily Insight Card
        UpwiseCard(
          backgroundColor: AppColors.accentSubtle,
          borderColor: AppColors.primaryLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('AI daily insight',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (dailyInsight != null && dailyInsight!.isNotEmpty)
                    ? dailyInsight!
                    : 'Focus on completing your top priority before switching contexts. Consistent 25-minute sprints produce more lasting progress than fragmented multi-tasking.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
