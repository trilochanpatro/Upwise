import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upwise/app/app.dart';
import 'package:upwise/core/network/upwise_api_client.dart';
import 'package:upwise/features/onboarding/models/onboarding_model.dart';
import 'package:upwise/features/shell/screens/app_shell.dart';

void main() {
  testWidgets('Upwise app prompts signed-out users to sign in',
      (WidgetTester tester) async {
    final supabaseClient = SupabaseClient(
      'https://example.supabase.co',
      'test-publishable-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(supabaseClient.auth.dispose);
    final apiClient = UpwiseApiClient(
      accessToken: () => null,
      baseUrl: 'http://localhost:8000',
      httpClient:
          MockClient((_) async => throw StateError('Unexpected request')),
    );

    await tester.pumpWidget(
      UpwiseApp(
        supabaseClient: supabaseClient,
        apiClient: apiClient,
      ),
    );

    expect(find.text('Sign in to Upwise'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('New to Upwise? Create an account'), findsOneWidget);
  });

  testWidgets('AppShell loads DB goals, tasks, insight and AI Coach chat',
      (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/goals' && request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'id': 'g-1',
              'title': 'Ship Upwise MVP',
              'description': 'Connect DB and AI',
              'category': 'Career',
              'progress': 50.0,
              'is_archived': false,
              'created_at': '2026-11-11T10:00:00Z',
            }
          ]),
          200,
        );
      }
      if (path == '/api/v1/tasks' && request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {
              'id': 't-1',
              'title': 'Verify database sync',
              'description': null,
              'category': 'Career',
              'estimated_minutes': 25,
              'priority': 'high',
              'is_completed': false,
              'goal_id': 'g-1',
              'created_at': '2026-11-11T10:00:00Z',
            }
          ]),
          200,
        );
      }
      if (path == '/api/v1/coach/insight' && request.method == 'GET') {
        return http.Response(
          jsonEncode({
            'insight': 'Start with Verify database sync (25m).',
            'focus_task_title': 'Verify database sync',
            'mode': 'smart_coach',
          }),
          200,
        );
      }
      if (path == '/api/v1/coach/history' && request.method == 'GET') {
        return http.Response(jsonEncode([]), 200);
      }
      if (path == '/api/v1/coach/chat' && request.method == 'POST') {
        return http.Response(
          jsonEncode({
            'id': 'm-1',
            'reply': 'Let us break that down into one 25-min focus block.',
            'mode': 'smart_coach',
            'proposed_task': {
              'title': '25-min focus sprint',
              'description': 'Stay focused on one priority',
              'category': 'Focus',
              'estimated_minutes': 25,
              'priority': 'high',
            },
            'created_at': '2026-11-11T10:05:00Z',
          }),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final apiClient = UpwiseApiClient(
      accessToken: () => 'dev-test-token',
      baseUrl: 'http://localhost:8000',
      httpClient: mockClient,
    );
    addTearDown(apiClient.close);

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          profile: OnboardingProfile(
            lifeStage: 'Employed professional',
            primaryGoalArea: 'Career & Skills',
            dailyTimeCommitment: '45 mins/day',
            preferredStyle: 'Action-oriented',
            isCompleted: true,
          ),
          apiClient: apiClient,
          onRestartOnboarding: () {},
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Home dashboard shows DB task & DB insight
    expect(find.text('Verify database sync'), findsOneWidget);
    expect(find.text('Start with Verify database sync (25m).'), findsOneWidget);

    // Switch to Goals tab
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    expect(find.text('Ship Upwise MVP'), findsOneWidget);

    // Switch to AI Coach tab and send a message
    await tester.tap(find.text('AI Coach'));
    await tester.pumpAndSettle();
    expect(find.text('Smart Coach'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Help me focus');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Let us break that down into one 25-min focus block.'),
        findsOneWidget);
    expect(find.text('Accept into Priorities'), findsOneWidget);
  });
}
