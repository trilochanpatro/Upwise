class OnboardingProfile {
  OnboardingProfile({
    this.lifeStage = '',
    this.primaryGoalArea = '',
    this.dailyTimeCommitment = '',
    this.preferredStyle = '',
    this.additionalContext = '',
    this.isCompleted = false,
  });

  String lifeStage;
  String primaryGoalArea;
  String dailyTimeCommitment;
  String preferredStyle;
  String additionalContext;
  bool isCompleted;

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      lifeStage: json['life_stage'] as String? ?? '',
      primaryGoalArea: json['primary_goal_area'] as String? ?? '',
      dailyTimeCommitment: json['daily_time_commitment'] as String? ?? '',
      preferredStyle: json['preferred_style'] as String? ?? '',
      additionalContext: json['additional_context'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'life_stage': lifeStage,
      'primary_goal_area': primaryGoalArea,
      'daily_time_commitment': dailyTimeCommitment,
      'preferred_style': preferredStyle,
      'additional_context':
          additionalContext.isEmpty ? null : additionalContext,
      'is_completed': isCompleted,
    };
  }

  OnboardingProfile copyWith({
    String? lifeStage,
    String? primaryGoalArea,
    String? dailyTimeCommitment,
    String? preferredStyle,
    String? additionalContext,
    bool? isCompleted,
  }) {
    return OnboardingProfile(
      lifeStage: lifeStage ?? this.lifeStage,
      primaryGoalArea: primaryGoalArea ?? this.primaryGoalArea,
      dailyTimeCommitment: dailyTimeCommitment ?? this.dailyTimeCommitment,
      preferredStyle: preferredStyle ?? this.preferredStyle,
      additionalContext: additionalContext ?? this.additionalContext,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.aiPrompt,
    required this.subtitle,
    required this.options,
    this.allowCustomInput = true,
  });

  final String id;
  final String aiPrompt;
  final String subtitle;
  final List<String> options;
  final bool allowCustomInput;
}
