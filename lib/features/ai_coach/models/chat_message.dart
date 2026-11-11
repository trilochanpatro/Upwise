import '../../tasks/models/task_model.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.mode = 'smart_coach',
    this.suggestedActions = const [],
    this.proposedTask,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String mode;
  final List<String> suggestedActions;
  final TaskModel? proposedTask;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final proposedRaw = json['proposed_task'];
    TaskModel? proposed;
    if (proposedRaw is Map<String, dynamic>) {
      proposed = TaskModel(
        id: '',
        title: proposedRaw['title'] as String? ?? 'Action step',
        description: proposedRaw['description'] as String?,
        category: proposedRaw['category'] as String? ?? 'Personal',
        estimatedMinutes: proposedRaw['estimated_minutes'] as int? ?? 25,
        priority: proposedRaw['priority'] as String? ?? 'medium',
      );
    }

    return ChatMessage(
      id: json['id'] as String,
      text: (json['text'] ?? json['reply']) as String,
      isUser: json['is_user'] as bool? ?? false,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      mode: json['mode'] as String? ?? 'smart_coach',
      proposedTask: proposed,
    );
  }
}
