import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/upwise_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onUpdateProgress,
    this.onDeleteGoal,
  });

  final List<GoalModel> goals;
  final Future<bool> Function(
      String title, String category, String? description) onAddGoal;
  final Future<bool> Function(int index, double newProgress) onUpdateProgress;
  final Future<bool> Function(int index)? onDeleteGoal;

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'Career';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create New Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'What outcome do you want to achieve?',
                    labelText: 'Goal Title',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Why is this important? (optional)',
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Category:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: category,
                      items: const [
                        DropdownMenuItem(
                            value: 'Career', child: Text('Career')),
                        DropdownMenuItem(
                            value: 'Income', child: Text('Income')),
                        DropdownMenuItem(
                            value: 'Skills', child: Text('Skills')),
                        DropdownMenuItem(
                            value: 'Health', child: Text('Health')),
                        DropdownMenuItem(
                            value: 'Personal', child: Text('Personal')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
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
                  final saved = await onAddGoal(
                    text,
                    category,
                    descController.text.trim(),
                  );
                  if (saved && ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressAdjuster(BuildContext context, int index) {
    final goal = goals[index];
    double tempProgress = goal.progress;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Progress',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                goal.title,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current Completion:'),
                  Text(
                    '${(tempProgress * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ],
              ),
              Slider(
                value: tempProgress,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setSheetState(() => tempProgress = val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onDeleteGoal != null) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onPressed: () async {
                        final deleted = await onDeleteGoal!(index);
                        if (deleted && ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Delete'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final saved =
                            await onUpdateProgress(index, tempProgress);
                        if (saved && ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Center(child: Text('Save Progress')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        SectionHeader(
          title: 'Your goals',
          subtitle: 'Measurable outcomes connected to daily actions',
          action: IconButton.filledTonal(
            tooltip: 'Add Goal',
            onPressed: () => _showAddGoalDialog(context),
            icon: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 8),
        if (goals.isEmpty)
          const UpwiseCard(
            padding: EdgeInsets.all(28),
            child: Center(
              child: Text(
                'No goals yet. Tap + to set your first milestone!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...List.generate(goals.length, (i) {
            final goal = goals[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UpwiseCard(
                onTap: () => _showProgressAdjuster(context, i),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            goal.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(goal.progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.tune,
                            size: 16, color: AppColors.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (goal.description != null &&
                        goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ProgressBar(
                      value: goal.progress,
                      height: 7,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
