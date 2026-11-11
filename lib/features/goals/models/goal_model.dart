class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Personal',
    this.progress = 0.0,
    this.targetDate,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final double progress; // 0.0 to 1.0
  final DateTime? targetDate;
  final bool isArchived;

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Personal',
      progress: ((json['progress'] as num?) ?? 0).toDouble() / 100,
      isArchived: json['is_archived'] as bool? ?? false,
      targetDate: json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String),
    );
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? progress,
    DateTime? targetDate,
    bool? isArchived,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      targetDate: targetDate ?? this.targetDate,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
