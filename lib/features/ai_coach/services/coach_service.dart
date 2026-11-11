import 'dart:math';
import '../models/chat_message.dart';
import '../../tasks/models/task_model.dart';

class CoachService {
  final List<String> _quickPrompts = [
    "I'm feeling overwhelmed today. Help me prioritize.",
    "How can I break down my career goal into 30-min steps?",
    "Review my daily focus and suggest a quick win.",
    "I have 45 minutes free right now. What should I tackle?",
  ];

  List<String> get quickPrompts => _quickPrompts;

  ChatMessage generateInitialMessage() {
    return ChatMessage(
      id: 'welcome_1',
      text: "Hi! I'm your Upwise Coach. I'm here to turn your ambitions into realistic daily steps that fit your real-world schedule and energy.\n\nWhat would you most like to make progress on today?",
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: const [
        "Prioritize today's tasks",
        "Set a new milestone",
        "Focus session advice",
      ],
    );
  }

  Future<ChatMessage> respondToUser(String input) async {
    // Simulate brief network latency for realistic UX feel
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = input.toLowerCase();
    final random = Random();

    if (normalized.contains('overwhelm') || normalized.contains('stress') || normalized.contains('too much')) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "When things feel overwhelming, the best move is ruthless simplification. Let's pick just ONE single needle-mover for today and let the rest wait.\n\nWould you like me to schedule a 25-minute deep focus block for your highest-priority item?",
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: const ["Pick 1 top task", "Review tomorrow instead"],
        proposedTask: TaskModel(
          id: 'ai_task_${random.nextInt(10000)}',
          title: 'Single 25-minute deep focus block',
          description: 'Focus on your highest priority without checking phone or tabs',
          category: 'Focus',
          estimatedMinutes: 25,
          priority: 'high',
        ),
      );
    }

    if (normalized.contains('career') || normalized.contains('job') || normalized.contains('interview') || normalized.contains('resume')) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Career progress compounds from consistent weekly actions rather than occasional sprints. Let's isolate one specific deliverable:\n\n1. Target 2 key skills or role requirements.\n2. Dedicate 30 minutes to practicing or building proof-of-work.\n\nShall we add this as an actionable priority for your week?",
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: ["Add 30-min skill practice", "Explore career roadmap"],
        proposedTask: TaskModel(
          id: 'ai_task_${random.nextInt(10000)}',
          title: 'Dedicate 30 mins to career portfolio / proof-of-work',
          description: 'Build or refine an artifact showcasing your primary capability',
          category: 'Career',
          estimatedMinutes: 30,
          priority: 'high',
        ),
      );
    }

    if (normalized.contains('time') || normalized.contains('minutes') || normalized.contains('schedule') || normalized.contains('free')) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "If you have limited time today, momentum is what matters. A 20-minute focused sprint will keep your streak alive and build psychological wins.\n\nI recommend tackling a single discrete action right now.",
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: ["Start 20-min sprint", "Log progress"],
      );
    }

    // Default intelligent response
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Thanks for sharing that. To make this actionable:\n\n1. What is the specific result you want to see by this weekend?\n2. What constraint (time, energy, or tools) is currently in your way?\n\nTell me, and I'll shape an adaptable, step-by-step plan for you.",
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: const [
        "Time is limited",
        "Need better focus",
        "Clarify my goal first",
      ],
    );
  }
}
