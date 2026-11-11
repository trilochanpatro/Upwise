import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/upwise_card.dart';
import '../../../core/widgets/progress_bar.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  final void Function(OnboardingProfile profile) onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final OnboardingProfile _profile = OnboardingProfile();
  final TextEditingController _customController = TextEditingController();

  final List<OnboardingQuestion> _questions = const [
    OnboardingQuestion(
      id: 'life_stage',
      aiPrompt: "To make your plan realistic, tell me a bit about your current life stage.",
      subtitle: "Plans adapt whether you are studying, working, or building something new.",
      options: [
        "Student & preparing for career",
        "Employed professional",
        "Freelancer / Independent",
        "Entrepreneur / Founder",
        "Exploring career transition",
      ],
    ),
    OnboardingQuestion(
      id: 'primary_goal',
      aiPrompt: "What is your biggest personal priority or outcome right now?",
      subtitle: "We'll focus our AI coaching around this high-impact area.",
      options: [
        "Build key skills & portfolio",
        "Advance career & income",
        "Build consistent focus & routines",
        "Balance health, work & wellbeing",
        "Launch a personal project",
      ],
    ),
    OnboardingQuestion(
      id: 'time_commitment',
      aiPrompt: "How much focused time can you realistically invest each day?",
      subtitle: "We prioritize small daily execution over unrealistic promises.",
      options: [
        "15–30 minutes daily (Quick wins)",
        "45–60 minutes daily (Steady pace)",
        "1.5–2 hours daily (Accelerated)",
        "Weekends only (Flexible sprints)",
      ],
    ),
    OnboardingQuestion(
      id: 'coaching_style',
      aiPrompt: "What kind of coaching style helps you take consistent action?",
      subtitle: "You can adjust this anytime in your preferences.",
      options: [
        "Action-oriented & direct",
        "Gentle, encouraging & flexible",
        "Analytical & milestone-driven",
        "Accountability partner with check-ins",
      ],
    ),
  ];

  bool get _isSummaryStep => _currentStep >= _questions.length;

  void _selectOption(String option) {
    setState(() {
      switch (_currentStep) {
        case 0:
          _profile.lifeStage = option;
          break;
        case 1:
          _profile.primaryGoalArea = option;
          break;
        case 2:
          _profile.dailyTimeCommitment = option;
          break;
        case 3:
          _profile.preferredStyle = option;
          break;
      }
      _advanceStep();
    });
  }

  void _submitCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) {
      _skipCurrent();
      return;
    }
    setState(() {
      switch (_currentStep) {
        case 0:
          _profile.lifeStage = text;
          break;
        case 1:
          _profile.primaryGoalArea = text;
          break;
        case 2:
          _profile.dailyTimeCommitment = text;
          break;
        case 3:
          _profile.preferredStyle = text;
          break;
      }
      _customController.clear();
      _advanceStep();
    });
  }

  void _skipCurrent() {
    setState(() {
      switch (_currentStep) {
        case 0:
          _profile.lifeStage = "General Growth";
          break;
        case 1:
          _profile.primaryGoalArea = "Personal Development";
          break;
        case 2:
          _profile.dailyTimeCommitment = "30 mins / day";
          break;
        case 3:
          _profile.preferredStyle = "Balanced & practical";
          break;
      }
      _advanceStep();
    });
  }

  void _advanceStep() {
    _currentStep++;
    _customController.clear();
  }

  void _confirmAndStart() {
    _profile.isCompleted = true;
    widget.onComplete(_profile);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isSummaryStep
        ? 1.0
        : (_currentStep + 1) / (_questions.length + 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Welcome to Upwise', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          if (!_isSummaryStep)
            TextButton(
              onPressed: _skipCurrent,
              child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: ProgressBar(
            value: progress,
            height: 4,
            backgroundColor: AppColors.borderLight,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSummaryStep ? _buildSummaryView() : _buildQuestionView(),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentStep];

    return ListView(
      key: ValueKey<int>(_currentStep),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      children: [
        // AI Coach Message Bubble
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.psychology_alt_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI COACH DISCOVERY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.aiPrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        Text(
          'Select an option or write your own:',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(height: 12),

        // Quick Options List
        ...question.options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _selectOption(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked, color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Custom Answer Input
        if (question.allowCustomInput)
          UpwiseCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    decoration: const InputDecoration(
                      hintText: "Or type custom context...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onSubmitted: (_) => _submitCustom(),
                  ),
                ),
                IconButton.filled(
                  onPressed: _submitCustom,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 54),
        const SizedBox(height: 14),
        Text(
          'Your Growth Blueprint',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Here is what Upwise AI understood about your context. You can confirm or adjust this anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        UpwiseCard(
          child: Column(
            children: [
              _summaryRow('Current Situation', _profile.lifeStage.isEmpty ? 'General Growth' : _profile.lifeStage, Icons.person_pin_outlined),
              const Divider(color: AppColors.border, height: 24),
              _summaryRow('Primary Priority', _profile.primaryGoalArea.isEmpty ? 'Personal Development' : _profile.primaryGoalArea, Icons.flag_outlined),
              const Divider(color: AppColors.border, height: 24),
              _summaryRow('Daily Commitment', _profile.dailyTimeCommitment.isEmpty ? '30 mins / day' : _profile.dailyTimeCommitment, Icons.schedule_outlined),
              const Divider(color: AppColors.border, height: 24),
              _summaryRow('Coaching Preference', _profile.preferredStyle.isEmpty ? 'Balanced & practical' : _profile.preferredStyle, Icons.psychology_outlined),
            ],
          ),
        ),

        const SizedBox(height: 20),

        UpwiseCard(
          backgroundColor: AppColors.accentSubtle,
          borderColor: AppColors.primaryLight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your daily plan and coaching insights will now be personalized around your ${_profile.primaryGoalArea.toLowerCase()} priority.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        FilledButton(
          onPressed: _confirmAndStart,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Confirm & Enter Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
