class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Personal',
    this.estimatedMinutes = 25,
    this.priority = 'medium',
    this.isCompleted = false,
    this.goalId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final int estimatedMinutes;
  final String priority;
  final bool isCompleted;
  final String? goalId;
  final DateTime? createdAt;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Personal',
      estimatedMinutes: json['estimated_minutes'] as int? ?? 25,
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['is_completed'] as bool? ?? false,
      goalId: json['goal_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? estimatedMinutes,
    String? priority,
    bool? isCompleted,
    String? goalId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      goalId: goalId ?? this.goalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
