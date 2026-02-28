import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/network/supabase_client.dart';
import '../../../core/network/supabase_constants.dart';

enum AppAuthStatus {
  loading,
  unauthenticated,
  needsWorkspace,
  authenticated,
}

class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.organizationId,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String organizationId;
  final String fullName;
  final String role;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'member',
    );
  }
}

class AppAuthState {
  const AppAuthState({
    required this.status,
    this.session,
    this.user,
    this.profile,
  });

  const AppAuthState.loading() : this(status: AppAuthStatus.loading);
  const AppAuthState.unauthenticated() : this(status: AppAuthStatus.unauthenticated);

  final AppAuthStatus status;
  final supabase.Session? session;
  final supabase.User? user;
  final ProfileSummary? profile;
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  late final supabase.SupabaseClient _supabase;
  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  @override
  Future<AppAuthState> build() async {
    _supabase = ref.read(supabaseClientProvider);

    unawaited(_authStateSubscription?.cancel());
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      unawaited(refreshAuthState());
    });
    ref.onDispose(() {
      unawaited(_authStateSubscription?.cancel());
    });

    return _resolveAuthState();
  }

  Future<AppAuthState> _resolveAuthState() async {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session == null || user == null) {
      return const AppAuthState.unauthenticated();
    }

    final profile = await _fetchProfile(user.id);
    if (profile == null) {
      return AppAuthState(
        status: AppAuthStatus.needsWorkspace,
        session: session,
        user: user,
      );
    }

    return AppAuthState(
      status: AppAuthStatus.authenticated,
      session: session,
      user: user,
      profile: profile,
    );
  }

  Future<ProfileSummary?> _fetchProfile(String authUserId) async {
    final response = await _supabase
        .from('profiles')
        .select('id, organization_id, full_name, role')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileSummary.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<void> refreshAuthState({bool showLoading = false}) async {
    final previous = state;
    if (showLoading) {
      state = const AsyncLoading();
    }

    final next = await AsyncValue.guard(_resolveAuthState);
    state = next.hasError ? previous : next;
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _runAndRefresh(() async {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signInWithOtp({required String email}) async {
    await _supabase.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: SupabaseConstants.magicLinkRedirectUrl,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _runAndRefresh(() async {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      final activeSession = response.session ?? _supabase.auth.currentSession;
      if (activeSession == null) {
        throw const supabase.AuthException(
          'Sign-up completed, but no session was created. Check email confirmation settings.',
        );
      }
    });
  }

  Future<void> bootstrapWorkspace({
    required String businessName,
    required String timezone,
  }) async {
    await _runAndRefresh(() async {
      Future<supabase.FunctionResponse> invokeBootstrap(String accessToken) {
        return _supabase.functions.invoke(
          'auth-bootstrap',
          headers: {'Authorization': 'Bearer $accessToken'},
          body: {
            'business_name': businessName.trim(),
            'timezone': timezone,
          },
        );
      }

      final initialToken = await _ensureValidAccessToken();
      if (kDebugMode) {
        debugPrint(
          'Workspace bootstrap token (initial): ${_tokenDebugSummary(initialToken)}; '
          'user=${_supabase.auth.currentUser?.id}',
        );
      }
      supabase.FunctionResponse response;

      try {
        response = await invokeBootstrap(initialToken);
      } catch (error) {
        if (!_isJwtFailure(error)) {
          rethrow;
        }

        final refreshedToken = await _ensureValidAccessToken(
          forceRefresh: true,
        );
        if (kDebugMode) {
          debugPrint(
            'Workspace bootstrap token (refreshed): ${_tokenDebugSummary(refreshedToken)}; '
            'user=${_supabase.auth.currentUser?.id}',
          );
        }
        try {
          response = await invokeBootstrap(refreshedToken);
        } catch (retryError) {
          if (_isJwtFailure(retryError)) {
            await _supabase.auth.signOut(scope: supabase.SignOutScope.local);
            throw const supabase.AuthException(
              'Session is invalid for this Supabase project. Please sign in again.',
            );
          }
          rethrow;
        }
      }

      final payload = response.data;
      if (payload is! Map) {
        throw StateError('Invalid auth-bootstrap response payload.');
      }
      final payloadMap = Map<String, dynamic>.from(payload);

      final ok = payloadMap['ok'] == true;
      if (!ok) {
        final error = payloadMap['error'];
        if (error is Map && error['message'] is String) {
          throw Exception(error['message'] as String);
        }
        throw Exception('Workspace bootstrap failed.');
      }

      final data = payloadMap['data'];
      if (data is! Map) {
        throw StateError('auth-bootstrap did not return data.');
      }
      final dataMap = Map<String, dynamic>.from(data);

      if (dataMap['organization_id'] is! String || dataMap['profile_id'] is! String) {
        throw StateError('auth-bootstrap returned malformed IDs.');
      }
    });
  }

  Future<String> _ensureValidAccessToken({
    bool forceRefresh = false,
  }) async {
    var session = _supabase.auth.currentSession;
    if (session == null) {
      throw const supabase.AuthException(
          'Session expired. Please sign in again.',
      );
    }

    final expiresAt = session.expiresAt;
    final isExpiringSoon = expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(
            expiresAt * 1000,
          ).isBefore(DateTime.now().add(const Duration(minutes: 1)))
        : false;

    if (forceRefresh || isExpiringSoon || !_isAccessTokenStillValid(session.accessToken)) {
      final refreshResult = await _supabase.auth.refreshSession();
      session = refreshResult.session;
      if (session == null) {
        await _supabase.auth.signOut(scope: supabase.SignOutScope.local);
        throw const supabase.AuthException(
          'Session refresh failed. Please sign in again.',
        );
      }
    }

    if (!_isAccessTokenStillValid(session.accessToken)) {
      await _supabase.auth.signOut(scope: supabase.SignOutScope.local);
      throw const supabase.AuthException(
        'Session token is invalid or expired. Please sign in again.',
      );
    }

    return session.accessToken;
  }

  bool _isJwtFailure(Object error) {
    final raw = error.toString();
    return raw.contains('FunctionException(status: 401') ||
        raw.contains('Invalid JWT') ||
        raw.contains('Unauthorized');
  }

  bool _isAccessTokenStillValid(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return false;

    final exp = payload['exp'];
    int? expSeconds;
    if (exp is int) {
      expSeconds = exp;
    } else if (exp is num) {
      expSeconds = exp.toInt();
    } else if (exp is String) {
      expSeconds = int.tryParse(exp);
    }

    if (expSeconds == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
    return expiry.isAfter(DateTime.now().add(const Duration(seconds: 30)));
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
      return null;
    } catch (_) {
      return null;
    }
  }

  String _tokenDebugSummary(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return 'unparseable';

    final expRaw = payload['exp'];
    int? expSeconds;
    if (expRaw is int) {
      expSeconds = expRaw;
    } else if (expRaw is num) {
      expSeconds = expRaw.toInt();
    } else if (expRaw is String) {
      expSeconds = int.tryParse(expRaw);
    }

    final expIso = expSeconds == null
        ? 'n/a'
        : DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000).toIso8601String();

    final sub = payload['sub'] ?? 'n/a';
    final role = payload['role'] ?? payload['app_metadata'] ?? 'n/a';
    final aud = payload['aud'] ?? 'n/a';
    return 'sub=$sub aud=$aud role=$role exp=$expIso';
  }

  Future<void> signOut() async {
    await _runAndRefresh(() async {
      await _supabase.auth.signOut();
    });
  }

  Future<void> _runAndRefresh(Future<void> Function() action) async {
    final previous = state;
    state = const AsyncLoading();

    try {
      await action();
      state = await AsyncValue.guard(_resolveAuthState);
    } catch (error, stackTrace) {
      final resolved = await AsyncValue.guard(_resolveAuthState);
      state = resolved.hasError ? previous : resolved;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
