import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/upwise_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../goals/models/goal_model.dart';
import '../../tasks/models/task_model.dart';

class GrowthModuleItem {
  const GrowthModuleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.insights,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double score; // 0.0 to 1.0
  final List<String> insights;
}

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({
    super.key,
    this.goals = const [],
    this.tasks = const [],
  });

  final List<GoalModel> goals;
  final List<TaskModel> tasks;

  GrowthModuleItem _buildDimension({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> categories,
  }) {
    final lowerCats = categories.map((c) => c.toLowerCase()).toSet();
    final matchingGoals = goals
        .where((g) => lowerCats.contains(g.category.toLowerCase()))
        .toList();
    final matchingTasks = tasks
        .where((t) => lowerCats.contains(t.category.toLowerCase()))
        .toList();

    final completedTasks =
        matchingTasks.where((t) => t.isCompleted).toList();
    final completedMinutes = completedTasks.fold<int>(
      0,
      (sum, t) => sum + t.estimatedMinutes,
    );

    double score = 0.0;
    if (matchingGoals.isNotEmpty && matchingTasks.isNotEmpty) {
      final avgGoalProgress = matchingGoals.fold<double>(
            0.0,
            (sum, g) => sum + g.progress,
          ) /
          matchingGoals.length;
      final taskRatio = completedTasks.length / matchingTasks.length;
      score = (avgGoalProgress * 0.6 + taskRatio * 0.4).clamp(0.0, 1.0);
    } else if (matchingGoals.isNotEmpty) {
      score = (matchingGoals.fold<double>(0.0, (sum, g) => sum + g.progress) /
              matchingGoals.length)
          .clamp(0.0, 1.0);
    } else if (matchingTasks.isNotEmpty) {
      score = (completedTasks.length / matchingTasks.length).clamp(0.0, 1.0);
    }

    final insights = <String>[
      matchingGoals.isEmpty
          ? 'Active goals: None in $title yet'
          : 'Active goals: ${matchingGoals.length} (top: "${matchingGoals.first.title}")',
      matchingTasks.isEmpty
          ? 'Tasks logged: 0 priorities in $title'
          : 'Task execution: ${completedTasks.length}/${matchingTasks.length} completed ($completedMinutes mins invested)',
      if (score >= 0.7)
        'Momentum: Strong execution velocity'
      else if (score >= 0.3)
        'Momentum: Steady progress — keep daily sprints consistent'
      else
        'Tip: Add a goal or ask AI Coach for a 25-min starter task',
    ];

    return GrowthModuleItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      score: score,
      insights: insights,
    );
  }

  List<GrowthModuleItem> _computeModules() {
    final totalGoals = goals.length;
    final avgGoalScore = totalGoals == 0
        ? 0.0
        : goals.fold<double>(0.0, (s, g) => s + g.progress) / totalGoals;
    final totalTasks = tasks.length;
    final doneTasks = tasks.where((t) => t.isCompleted).length;
    final taskVelocity = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;
    final overallScore = (totalGoals == 0 && totalTasks == 0)
        ? 0.0
        : ((avgGoalScore + taskVelocity) / (totalGoals > 0 && totalTasks > 0 ? 2 : 1))
            .clamp(0.0, 1.0);

    final confidence = (totalGoals + totalTasks) >= 6
        ? 'High (backed by ${totalGoals + totalTasks} tracked records)'
        : (totalGoals + totalTasks) >= 2
            ? 'Medium (add more goals & tasks for sharper forecasts)'
            : 'Low (create at least 2 goals or tasks to calibrate)';

    return [
      _buildDimension(
        icon: Icons.work_outline,
        title: 'Career',
        subtitle: 'Trajectory & proof-of-work',
        categories: ['Career'],
      ),
      _buildDimension(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Income',
        subtitle: 'Revenue & savings stability',
        categories: ['Income'],
      ),
      _buildDimension(
        icon: Icons.school_outlined,
        title: 'Skills',
        subtitle: 'Technical & execution depth',
        categories: ['Skills'],
      ),
      _buildDimension(
        icon: Icons.psychology_outlined,
        title: 'Mental Focus',
        subtitle: 'Distraction control & deep work',
        categories: ['Focus', 'Personal'],
      ),
      _buildDimension(
        icon: Icons.favorite_border,
        title: 'Health',
        subtitle: 'Energy & daily stamina',
        categories: ['Health'],
      ),
      GrowthModuleItem(
        icon: Icons.query_stats_rounded,
        title: 'Future Scenarios',
        subtitle: 'Outcome velocity projection',
        score: overallScore,
        insights: [
          'Overall goal completion: ${(avgGoalScore * 100).round()}% across $totalGoals goal(s)',
          'Current priority velocity: $doneTasks of $totalTasks tasks completed',
          'Projection confidence: $confidence',
        ],
      ),
    ];
  }

  void _showModuleDetails(BuildContext context, GrowthModuleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(item.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                Text(
                  '${(item.score * 100).round()}% Index',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProgressBar(value: item.score, height: 6),
            const SizedBox(height: 20),
            const Text('Live Database Diagnostics:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            ...item.insights.map((ins) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(ins,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Center(child: Text('Close')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = _computeModules();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const SectionHeader(
          title: 'Your growth',
          subtitle: 'Live metrics computed from your synced goals and tasks',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final item = modules[index];
            return UpwiseCard(
              padding: const EdgeInsets.all(14),
              onTap: () => _showModuleDetails(context, item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon, color: AppColors.primary, size: 24),
                      Text(
                        '${(item.score * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  ProgressBar(value: item.score, height: 4),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        UpwiseCard(
          backgroundColor: AppColors.surfaceVariant,
          borderColor: AppColors.border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 18),
                  SizedBox(width: 8),
                  Text('Projections Methodology',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Dimension scores combine your synced goal completion with daily priority execution. Projections reflect current momentum and transparent assumptions rather than guarantees.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
