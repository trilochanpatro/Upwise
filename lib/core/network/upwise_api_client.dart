import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/ai_coach/models/chat_message.dart';
import '../../features/goals/models/goal_model.dart';
import '../../features/onboarding/models/onboarding_model.dart';
import '../../features/tasks/models/task_model.dart';

class UpwiseApiException implements Exception {
  const UpwiseApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpwiseApiClient {
  UpwiseApiClient({
    required String? Function() accessToken,
    http.Client? httpClient,
    String? baseUrl,
  })  : _accessToken = accessToken,
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'UPWISE_API_URL',
                  defaultValue: 'https://upwise-api-production.up.railway.app',
                ))
            .replaceFirst(RegExp(r'/+$'), '');

  final String? Function() _accessToken;
  final http.Client _httpClient;
  final String _baseUrl;

  // Profile & AI Memory
  Future<OnboardingProfile> getProfile() async {
    final response = await _request('profile');
    return OnboardingProfile.fromJson(_asObject(response));
  }

  Future<OnboardingProfile> saveProfile(OnboardingProfile profile) async {
    final response = await _request(
      'profile',
      method: 'PUT',
      body: profile.toJson(),
    );
    return OnboardingProfile.fromJson(_asObject(response));
  }

  Future<void> clearProfileMemory() async {
    await _request('profile', method: 'DELETE');
  }

  // Goals
  Future<List<GoalModel>> listGoals() async {
    final response = _asObjectList(await _request('goals'));
    return response.map(GoalModel.fromJson).toList();
  }

  Future<GoalModel> createGoal({
    required String title,
    required String category,
    String? description,
  }) async {
    final response = await _request(
      'goals',
      method: 'POST',
      body: {
        'title': title,
        'category': category,
        'description': description,
      },
    );
    return GoalModel.fromJson(_asObject(response));
  }

  Future<GoalModel> updateGoalProgress({
    required String id,
    required double progress,
  }) async {
    final response = await _request(
      'goals/$id/progress',
      method: 'PATCH',
      body: {'progress': progress * 100},
    );
    return GoalModel.fromJson(_asObject(response));
  }

  Future<void> deleteGoal(String id) async {
    await _request('goals/$id', method: 'DELETE');
  }

  // Tasks
  Future<List<TaskModel>> listTasks() async {
    final response = _asObjectList(await _request('tasks'));
    return response.map(TaskModel.fromJson).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _request(
      'tasks',
      method: 'POST',
      body: {
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'estimated_minutes': task.estimatedMinutes,
        'priority': task.priority,
        'goal_id': task.goalId,
      },
    );
    return TaskModel.fromJson(_asObject(response));
  }

  Future<TaskModel> updateTaskCompletion({
    required String id,
    required bool isCompleted,
  }) async {
    final response = await _request(
      'tasks/$id/completion',
      method: 'PATCH',
      body: {'is_completed': isCompleted},
    );
    return TaskModel.fromJson(_asObject(response));
  }

  Future<void> deleteTask(String id) async {
    await _request('tasks/$id', method: 'DELETE');
  }

  // AI Coach
  Future<List<ChatMessage>> getCoachHistory() async {
    final response = _asObjectList(await _request('coach/history'));
    return response.map(ChatMessage.fromJson).toList();
  }

  Future<void> clearCoachHistory() async {
    await _request('coach/history', method: 'DELETE');
  }

  Future<ChatMessage> sendCoachMessage(String message) async {
    final response = await _request(
      'coach/chat',
      method: 'POST',
      body: {'message': message},
    );
    return ChatMessage.fromJson(_asObject(response));
  }

  Future<String> getDailyInsight() async {
    final response = _asObject(await _request('coach/insight'));
    return response['insight'] as String? ??
        'Focus on one concrete priority today.';
  }

  List<Map<String, dynamic>> _asObjectList(dynamic value) {
    if (value is! List<dynamic> ||
        value.any((item) => item is! Map<String, dynamic>)) {
      throw const UpwiseApiException(
        'The Upwise API returned data in an unexpected format.',
      );
    }
    return value.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _asObject(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const UpwiseApiException(
        'The Upwise API returned data in an unexpected format.',
      );
    }
    return value;
  }

  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = _accessToken();
    if (token == null || token.isEmpty) {
      throw const UpwiseApiException('Sign in to sync your data.');
    }

    final uri = Uri.parse('$_baseUrl/api/v1/$path');
    final headers = {
      'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };

    late final http.Response response;
    try {
      if (method == 'POST') {
        response = await _httpClient
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 20));
      } else if (method == 'PUT') {
        response = await _httpClient
            .put(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      } else if (method == 'PATCH') {
        response = await _httpClient
            .patch(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      } else if (method == 'DELETE') {
        response = await _httpClient
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } else {
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      }
    } on http.ClientException catch (error) {
      throw UpwiseApiException('Could not connect to the Upwise API: $error');
    } on TimeoutException {
      throw const UpwiseApiException('The Upwise API request timed out.');
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw UpwiseApiException(
          'The Upwise API returned invalid data (HTTP ${response.statusCode}).',
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map<String, dynamic>
          ? decoded['detail']?.toString()
          : null;
      throw UpwiseApiException(
        detail ??
            'The Upwise API request failed (HTTP ${response.statusCode}).',
      );
    }

    return decoded;
  }

  void close() => _httpClient.close();
}
