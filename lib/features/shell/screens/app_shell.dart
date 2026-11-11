import 'package:flutter/material.dart';
import '../../../core/network/upwise_api_client.dart';
import '../../../core/widgets/upwise_logo.dart';
import '../../home/screens/home_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../ai_coach/screens/coach_screen.dart';
import '../../growth/screens/growth_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tasks/models/task_model.dart';
import '../../goals/models/goal_model.dart';
import '../../onboarding/models/onboarding_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.profile,
    required this.apiClient,
    required this.onRestartOnboarding,
    required this.onSignOut,
  });

  final OnboardingProfile profile;
  final UpwiseApiClient apiClient;
  final VoidCallback onRestartOnboarding;
  final Future<void> Function() onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  List<TaskModel> _tasks = [];
  List<GoalModel> _goals = [];
  String? _dailyInsight;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        widget.apiClient.listGoals(),
        widget.apiClient.listTasks(),
      ]);
      String? insight;
      try {
        insight = await widget.apiClient.getDailyInsight();
      } on UpwiseApiException {
        insight = null;
      }
      if (!mounted) return;
      setState(() {
        _goals = results[0] as List<GoalModel>;
        _tasks = results[1] as List<TaskModel>;
        _dailyInsight = insight;
        _isLoading = false;
      });
    } on UpwiseApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshInsight() async {
    try {
      final insight = await widget.apiClient.getDailyInsight();
      if (!mounted) return;
      setState(() => _dailyInsight = insight);
    } on UpwiseApiException {
      // Non-critical refresh
    }
  }

  Future<void> _toggleTask(int index) async {
    final task = _tasks[index];
    try {
      final updatedTask = await widget.apiClient.updateTaskCompletion(
        id: task.id,
        isCompleted: !task.isCompleted,
      );
      if (!mounted) return;
      setState(() {
        final currentIndex = _tasks.indexWhere((item) => item.id == task.id);
        if (currentIndex != -1) _tasks[currentIndex] = updatedTask;
      });
      _refreshInsight();
    } on UpwiseApiException catch (error) {
      _showError(error);
    }
  }

  Future<bool> _addTask(String title, String category, int minutes) async {
    try {
      final task = await widget.apiClient.createTask(
        TaskModel(
          id: '',
          title: title,
          category: category,
          estimatedMinutes: minutes,
          priority: 'high',
        ),
      );
      if (!mounted) return false;
      setState(() => _tasks.insert(0, task));
      _refreshInsight();
      return true;
    } on UpwiseApiException catch (error) {
      _showError(error);
      return false;
    }
  }

  Future<void> _deleteTask(int index) async {
    final task = _tasks[index];
    try {
      await widget.apiClient.deleteTask(task.id);
      if (!mounted) return;
      setState(() {
        _tasks.removeWhere((item) => item.id == task.id);
      });
      _refreshInsight();
    } on UpwiseApiException catch (error) {
      _showError(error);
    }
  }

  Future<bool> _addGoal(
    String title,
    String category,
    String? description,
  ) async {
    try {
      final goal = await widget.apiClient.createGoal(
        title: title,
        category: category,
        description: description?.trim().isEmpty == true ? null : description,
      );
      if (!mounted) return false;
      setState(() => _goals.add(goal));
      _refreshInsight();
      return true;
    } on UpwiseApiException catch (error) {
      _showError(error);
      return false;
    }
  }

  Future<bool> _updateGoalProgress(int index, double newProgress) async {
    final goal = _goals[index];
    try {
      final updatedGoal = await widget.apiClient.updateGoalProgress(
        id: goal.id,
        progress: newProgress,
      );
      if (!mounted) return false;
      setState(() {
        final currentIndex = _goals.indexWhere((item) => item.id == goal.id);
        if (currentIndex != -1) _goals[currentIndex] = updatedGoal;
      });
      _refreshInsight();
      return true;
    } on UpwiseApiException catch (error) {
      _showError(error);
      return false;
    }
  }

  Future<bool> _deleteGoal(int index) async {
    final goal = _goals[index];
    try {
      await widget.apiClient.deleteGoal(goal.id);
      if (!mounted) return false;
      setState(() {
        _goals.removeWhere((item) => item.id == goal.id);
      });
      _refreshInsight();
      return true;
    } on UpwiseApiException catch (error) {
      _showError(error);
      return false;
    }
  }

  Future<bool> _acceptProposedTask(TaskModel proposedTask) async {
    try {
      final task = await widget.apiClient.createTask(proposedTask);
      if (!mounted) return false;
      setState(() => _tasks.insert(0, task));
      _refreshInsight();
      return true;
    } on UpwiseApiException catch (error) {
      _showError(error);
      return false;
    }
  }

  Future<void> _clearAiMemory() async {
    try {
      await Future.wait([
        widget.apiClient.clearProfileMemory(),
        widget.apiClient.clearCoachHistory(),
      ]);
    } on UpwiseApiException catch (error) {
      _showError(error);
    }
  }

  void _showError(UpwiseApiException error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your goals and tasks.'),
              const SizedBox(height: 8),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      HomeScreen(
        tasks: _tasks,
        onToggleTask: _toggleTask,
        onAddTask: _addTask,
        onDeleteTask: _deleteTask,
        dailyInsight: _dailyInsight,
        profile: widget.profile,
      ),
      GoalsScreen(
        goals: _goals,
        onAddGoal: _addGoal,
        onUpdateProgress: _updateGoalProgress,
        onDeleteGoal: _deleteGoal,
      ),
      CoachScreen(
        apiClient: widget.apiClient,
        onAcceptProposedTask: _acceptProposedTask,
      ),
      GrowthScreen(
        goals: _goals,
        tasks: _tasks,
      ),
      ProfileScreen(
        profile: widget.profile,
        onRestartOnboarding: widget.onRestartOnboarding,
        onSignOut: widget.onSignOut,
        onClearAiMemory: _clearAiMemory,
      ),
    ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UpwiseLogo(size: 32, borderRadius: 9),
            const SizedBox(width: 10),
            Text(
              'Upwise',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sync Data',
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Notifications configured for 8:30 AM check-ins.')),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'AI Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Growth',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
