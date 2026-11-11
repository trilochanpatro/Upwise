import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/upwise_api_client.dart';
import '../../../core/widgets/upwise_card.dart';
import '../models/chat_message.dart';
import '../services/coach_service.dart';
import '../../tasks/models/task_model.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({
    super.key,
    required this.apiClient,
    required this.onAcceptProposedTask,
  });

  final UpwiseApiClient apiClient;
  final Future<bool> Function(TaskModel task) onAcceptProposedTask;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final CoachService _coachService = CoachService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  String _engineMode = 'smart_coach';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await widget.apiClient.getCoachHistory();
      if (!mounted) return;
      setState(() {
        _messages.clear();
        if (history.isEmpty) {
          _messages.add(_coachService.generateInitialMessage());
        } else {
          _messages.addAll(history);
          final lastCoachMsg = history.lastWhere(
            (m) => !m.isUser,
            orElse: () => history.last,
          );
          if (!lastCoachMsg.isUser) {
            _engineMode = lastCoachMsg.mode;
          }
        }
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    } on UpwiseApiException {
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.add(_coachService.generateInitialMessage());
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    try {
      await widget.apiClient.clearCoachHistory();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(_coachService.generateInitialMessage());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation history cleared.')),
      );
    } on UpwiseApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await widget.apiClient.sendCoachMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(response);
        _engineMode = response.mode;
        _isLoading = false;
      });
      _scrollToBottom();
    } on UpwiseApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  String get _modeLabel {
    if (_engineMode == 'live_ai') return 'Live AI';
    if (_engineMode == 'smart_coach') return 'Smart Coach';
    return 'Synced';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Coach Status Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.psychology_alt_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upwise Intelligence',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 3, backgroundColor: AppColors.success),
                      SizedBox(width: 5),
                      Text('Context-Aware Coach',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_modeLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Clear chat history',
                onPressed: _clearHistory,
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // Chat Message List
        Expanded(
          child: _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageItem(message);
                  },
                ),
        ),

        // Thinking indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
                SizedBox(width: 10),
                Text('Coach is analyzing your goals & priorities...',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

        // Quick prompts suggestions horizontal strip
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: _coachService.quickPrompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () => _handleSend(prompt),
                ),
              );
            }).toList(),
          ),
        ),

        // Input Box
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Discuss goals, hurdles, or plan steps...',
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isLoading ? null : () => _handleSend(),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      message.isUser ? const Radius.circular(18) : Radius.zero,
                  bottomRight:
                      message.isUser ? Radius.zero : const Radius.circular(18),
                ),
                border:
                    message.isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),

            // Optional Proposed Action Task Box
            if (message.proposedTask != null) ...[
              const SizedBox(height: 6),
              UpwiseCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: AppColors.surfaceVariant,
                borderColor: AppColors.primaryLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        const Text('Recommended Action',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const Spacer(),
                        Text('${message.proposedTask!.estimatedMinutes}m',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.proposedTask!.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () async {
                        final saved = await widget.onAcceptProposedTask(
                          message.proposedTask!,
                        );
                        if (!mounted || !saved) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to today\'s priorities!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add,
                          size: 16, color: AppColors.primary),
                      label: const Text('Accept into Priorities',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
