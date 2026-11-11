import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:upwise/core/network/upwise_api_client.dart';

void main() {
  test('loads authenticated goals and converts API progress to UI fraction',
      () async {
    late http.Request receivedRequest;
    final client = UpwiseApiClient(
      accessToken: () => 'access-token',
      baseUrl: 'https://api.example.com/',
      httpClient: MockClient((request) async {
        receivedRequest = request;
        return http.Response(
          jsonEncode([
            {
              'id': 'goal-1',
              'title': 'Build a portfolio',
              'description': null,
              'category': 'Career',
              'progress': 45.0,
              'is_archived': false,
              'created_at': '2026-01-01T00:00:00Z',
            },
          ]),
          200,
        );
      }),
    );
    addTearDown(client.close);

    final goals = await client.listGoals();

    expect(
        receivedRequest.url.toString(), 'https://api.example.com/api/v1/goals');
    expect(receivedRequest.headers['Authorization'], 'Bearer access-token');
    expect(goals.single.progress, 0.45);
  });

  test('surfaces API errors instead of treating them as empty data', () async {
    final client = UpwiseApiClient(
      accessToken: () => 'expired-token',
      baseUrl: 'https://api.example.com',
      httpClient: MockClient(
        (_) async =>
            http.Response(jsonEncode({'detail': 'Invalid token'}), 401),
      ),
    );
    addTearDown(client.close);

    expect(
      client.listTasks(),
      throwsA(
        isA<UpwiseApiException>().having(
          (error) => error.message,
          'message',
          'Invalid token',
        ),
      ),
    );
  });

  test('sends goal progress in the percentage format expected by the API',
      () async {
    late http.Request receivedRequest;
    final client = UpwiseApiClient(
      accessToken: () => 'access-token',
      baseUrl: 'https://api.example.com',
      httpClient: MockClient((request) async {
        receivedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 'goal-1',
            'title': 'Build a portfolio',
            'description': null,
            'category': 'Career',
            'progress': 45.0,
            'is_archived': false,
            'created_at': '2026-01-01T00:00:00Z',
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);

    await client.updateGoalProgress(id: 'goal-1', progress: 0.45);

    expect(
      receivedRequest.url.toString(),
      'https://api.example.com/api/v1/goals/goal-1/progress',
    );
    expect(jsonDecode(receivedRequest.body), {'progress': 45.0});
  });
}
