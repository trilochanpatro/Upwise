import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/network/upwise_api_client.dart';
import '../features/auth/screens/auth_screen.dart';
import 'theme/app_theme.dart';
import '../features/onboarding/models/onboarding_model.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/shell/screens/app_shell.dart';

class UpwiseApp extends StatefulWidget {
  const UpwiseApp({
    super.key,
    this.supabaseClient,
    this.apiClient,
  });

  final SupabaseClient? supabaseClient;
  final UpwiseApiClient? apiClient;

  @override
  State<UpwiseApp> createState() => _UpwiseAppState();
}

class _UpwiseAppState extends State<UpwiseApp> {
  late final SupabaseClient _supabaseClient;
  late final UpwiseApiClient _apiClient;
  late final bool _ownsApiClient;
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;

  bool _isLoadingProfile = false;
  bool _isOnboardingCompleted = false;
  OnboardingProfile _profile = OnboardingProfile();

  @override
  void initState() {
    super.initState();
    _supabaseClient = widget.supabaseClient ?? Supabase.instance.client;
    _session = _supabaseClient.auth.currentSession;
    _ownsApiClient = widget.apiClient == null;
    _apiClient = widget.apiClient ??
        UpwiseApiClient(
          accessToken: () => _supabaseClient.auth.currentSession?.accessToken,
        );
    if (_session != null) {
      _loadProfile();
    }
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final previousUserId = _session?.user.id;
      final newSession = data.session;
      final newUserId = newSession?.user.id;

      setState(() {
        _session = newSession;
        if (newSession == null) {
          _isOnboardingCompleted = false;
          _isLoadingProfile = false;
          _profile = OnboardingProfile();
        }
      });

      // Only fetch profile when a user newly signs in or switches accounts,
      // not on background JWT tokenRefreshed events.
      if (newSession != null && newUserId != previousUserId) {
        _loadProfile();
      }
    });
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final fetched = await _apiClient.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = fetched;
        _isOnboardingCompleted = fetched.isCompleted;
        _isLoadingProfile = false;
      });
    } on UpwiseApiException {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    if (_ownsApiClient) _apiClient.close();
    super.dispose();
  }

  Future<void> _completeOnboarding(OnboardingProfile completedProfile) async {
    setState(() {
      _profile = completedProfile;
      _isOnboardingCompleted = true;
    });
    try {
      final saved = await _apiClient.saveProfile(completedProfile);
      if (!mounted) return;
      setState(() {
        _profile = saved;
      });
    } on UpwiseApiException {
      // Keep local state active; AppShell retry/sync remains available.
    }
  }

  void _restartOnboarding() {
    setState(() {
      _isOnboardingCompleted = false;
    });
  }

  Widget _buildHome() {
    if (_session == null) {
      return AuthScreen(supabaseClient: _supabaseClient);
    }
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userId = _session!.user.id;
    if (_isOnboardingCompleted) {
      return AppShell(
        key: ValueKey('shell_$userId'),
        profile: _profile,
        apiClient: _apiClient,
        onRestartOnboarding: _restartOnboarding,
        onSignOut: _supabaseClient.auth.signOut,
      );
    }
    return OnboardingScreen(
      key: ValueKey('onboarding_$userId'),
      onComplete: _completeOnboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildHome(),
    );
  }
}
